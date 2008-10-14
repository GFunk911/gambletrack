class Spread
  attr_accessor :fb
  def initialize(fb)
    @fb = fb ? fb.to_closest_spread : fb
  end
  def to_s
    if fb > 0
      "-#{fb}"
    else
      "+#{fb*-1}"
    end
  end
end
  
module LineSingleBet
  fattr(:single_bet) do
    bets.empty? ? new_bet : bets.first
  end
  def new_bet
    #puts "line id #{self.id}"
    bets.new.tap { |x| x.save! if x.line_id }
  end
  %w(desired_amount outstanding_amount wagered_amount).each do |meth|
    writ = "#{meth}="
    define_method(meth) { single_bet.send(meth) }
    define_method(writ) { |x| single_bet.send(writ,x) }
  end
  def save_single_bet!
    #puts "calling save_single_bet!"
    raise "line has no id" unless self.id
    single_bet.line_id = id
    single_bet.save!
  end
  def has_bet?
    (wagered_amount||0) > 0 or (desired_amount||0) > 0
  end
  def win_amount
    single_bet.win_amount
  end
end

class Time
  def pretty_dt
    strftime("%m/%d %H:%M")
  end
end

class Line < ActiveRecord::Base
  include LineSingleBet
  after_save { |x| x.save_single_bet! }
  before_save { |x| x.effective_dt ||= Time.now }
  belongs_to :game
  belongs_to :site
  has_many :bets
  belongs_to :team_obj, :class_name => 'Team', :foreign_key => 'team_id'
  belongs_to :line_set
  validates_presence_of :odds
  validates_presence_of :site
  validates_presence_of :game
  named_scope :active, lambda { {:conditions => ["expire_dt is null",Time.now]} }
  before_save { |x| x.find_or_create_line_set }
  after_create { |x| x.line_set.mark_active! }
  has_many :consensus, :class_name => 'LineConsensus'
  #include BetSummary
  def team
    team_obj.short_name
  end
  def save
    #puts "calling Line#save"
    super
  end
  def self.load_lines
    gs = Game.week(3)
    Lines.current_lines.each do |ln|
      g = gs.teams(ln.away_team,ln.home_team).first
      new(:game_id => g.id, :spread => ln.line, :return_from_dollar => Gambling::Odds.get(ln.home_odds).rfd, :status => 'Open', :team => ln.home_team).save!
      new(:game_id => g.id, :spread => ln.line*-1, :return_from_dollar => Gambling::Odds.get(ln.away_odds).rfd, :status => 'Open', :team => ln.away_team).save!
    end
  end
  def odds
    return_from_dollar ? Gambling::Odds.new(return_from_dollar) : ''
  end
  def odds=(x)
    self.return_from_dollar = x.blank? ? nil : Gambling::Odds.get(x).rfd
  end
  def desc
    "#{team} #{spr} #{odds}"
  rescue => exp
    puts exp
    return "line desc"
  end
  def spr
    Spread.new(spread)
  end
  def ha
    (game.home_team == team)
  end
  def home_favored_factor
    (ha ? 1 : -1)
  end
  def home_favored
     (home_favored_factor * spread).to_closest_spread
  end
  def wager
    Gambling::Wager.new(home_favored,game.correct_spread,ha,odds,game)
  end
  def wagers
    return [] unless game.sport.abbr == 'NFL'
    #[wager,teaser_wager].select { |x| x }
    [wager].select { |x| x }
  end
  def teaser_wager
    return nil if home_favored == 0
    act = home_favored - 6*home_favored_factor
    Gambling::Teaser.new(act,game.correct_spread,ha,Gambling::Odds.get('-261'),game, :bet_type => 'TEASER')
  end
  def childrenx
    bets
  end
  def actual_margin
    game.team_margin(team)
  end
  def result
    return :unplayed unless game.played?
    margin = actual_margin - spread
    return :win if margin > 0
    return :loss if margin < 0
    return :push
  rescue => exp
    puts exp
    return :error
  end
  def result_factor
    h = {:unplayed => 0, :push => 0, :win => 1*odds, :loss => -1}
    h[result]
  end
  def pretty_spread
    return spread unless spread
    spread * -1
  end
  def pretty_spread=(x)
    self.spread = (x ? x.to_f * -1 : x)
  end
  def possible_teams
    if game
      game.teams
    else
      Team.all
    end
  end
  def self.find_or_create_from_hash(h)
    LineCreator.new(h).run!
  end
  def bet_type
    (spread.to_f == 0.0) ? 'moneyline' : 'spread'
  end
  def find_or_create_line_set
    return line_set if line_set
    if site.changes_spread?
      set = LineSet.find(:first, :conditions => ["site_id = ? and game_id = ? and bet_type = ? and team_id = ?",site_id,game_id,bet_type,team_id])
      set ||= LineSet.new(:game_id => game_id, :site_id => site_id, :bet_type => bet_type, :team_id => team_id).tap { |x| x.save! }
      self.line_set = set
      set
    else
      set = LineSet.find(:first, :conditions => ["site_id = ? and game_id = ? and spread = ? and team_id = ?",site_id,game_id,spread,team_id])
      set ||= LineSet.new(:game_id => game_id, :site_id => site_id, :spread => spread.to_closest_spread, :team_id => team_id).tap { |x| x.save! }
      self.line_set = set
      set
    end
  end
  def self.reset_lineset!
    LineSet.find(:all).each { |x| x.destroy }
    find(:all).each { |x| x.line_set = nil; x.save! }
    LineSet.find(:all).each { |x| x.mark_active! }
  end
  def active?
    !expired? || has_bet?
  end
  def expired?
    !!expire_dt
  end
  def expired
    !!expire_dt
  end
  def expired=(x)
    x = (x and x.to_i == 1)
    self.expire_dt ||= Time.now if x
    self.expire_dt = nil if !x
  end
  def sort_array
    a = new_record? ? 99999 : self.line_set_id
    b = expire_dt ? expire_dt : 999.days.ago
    [a,b]
  end
  def corrected_rfd
    Gambling::Odds.get(odds.to_s).rfd
  end
  def add_consensus(h)
    num,pct = (h[:bets]||0).to_i, h[:bet_percent].to_f
    if consensus.select { |x| x.bets.to_i == num and x.bet_percent == pct }.empty?
      consensus.new(:bets => num, :bet_percent => pct).save!
    end
  end
end

class Module
  def fattr_nn(name,&b)
    fattr(name) do 
      instance_eval(&b).tap { |x| raise "#{name} returning #{x.class}" unless x }
    end
  end
end

module Enumerable
  def comp_array
    map { |x| x.is_a?(Team) ? "#{x.id} #{x.abbr}" : x }.map { |x| [x,x.class] }.flatten
  end
  def eq_comp(b)
    res = (comp_array == b.comp_array)
    puts "#{res} #{comp_array.inspect} #{b.comp_array.inspect}"
  end
end

module GLCreator
  attr_accessor :h
  def initialize(h)
    @h = h
  end
  fattr(:event_dt) { h[:event_dt] }
  fattr_nn(:sport) do
    Sport.find_by_abbr(h[:sport])
  end
  def team(t)
    sport.find_team(t).tap { |x| raise "no team found for #{t}" unless x and t }
  end
  fattr_nn(:home_team) { team(h[:home_team]) }
  fattr_nn(:away_team) { team(h[:away_team]) }
  fattr_nn(:period) do
    event_dt ? sport.periods.all_containing(event_dt).first : Period.find(6)
  end
  def pretty_dt
    event_dt ? event_dt.pretty_dt : ""
  end
  fattr(:existing_game) do
    sport.games.find(:first, :conditions => {:period_id => period.id, :home_team_id => home_team.id, :away_team_id => away_team.id})
  end
end

class GameCreator
  include GLCreator
  fattr(:new_game) do
    sport.games.new(:period_id => period.id, :home_team_id => home_team.id, :away_team_id => away_team.id, :event_dt => event_dt).tap { |x| x.save! }
  end
  fattr(:desc) { "#{away_team}@#{home_team} #{pretty_dt}" }
  def run!
    puts(existing_game ? "Found #{desc}" : "Creating #{desc}")
    existing_game || new_game
  end
end

class LineCreator
  include GLCreator
  fattr_nn(:site) do
    Site.find(:first, :conditions => {:name => h[:site]})
  end
  fattr_nn(:selected_team) { team(h[:team]) }
  def odds
    Gambling::Odds.get(h[:odds])
  end
  def spread
     h[:spread].to_closest_spread
  end
  fattr_nn(:game) { existing_game }
  fattr(:existing_line) do 
    game.lines.select do |x| 
      #line_compare_array(x).eq_comp(compare_array)
      #puts (0.694).round_dec(3).round_dec(3).round_dec(3)
      x.spread.to_closest_spread == spread and x.odds.to_s == odds.to_s and x.team_obj == selected_team and x.site_id == site.id 
    end.first
  end
  fattr(:new_line) do 
    game.lines.new(:team_id => selected_team.id, :return_from_dollar => odds.rfd, :spread => spread, :site => site).tap { |x| x.save! }
  end
  fattr(:desc) do
    "#{away_team}@#{home_team} #{selected_team} #{spread} #{odds} #{pretty_dt}"
  end
  def run!
    #return unless away_team.abbr == 'STL'
    puts(existing_line ? "Found #{desc}" : "Creating #{desc}")
    existing_line || new_line
  end
end

class ConsensusCreator
  attr_accessor :h
  def initialize(h)
    @h = h
  end
  fattr(:line) { Line.find_or_create_from_hash(h) }
  def run!
    line.add_consensus(h)
  end
end

