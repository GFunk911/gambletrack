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

module LineTypes
  def self.line_type_hash
    {:spread => 'SpreadLine', :ml => 'MoneyLine', :ou => 'OverUnderLine'}
  end
  LineTypes.line_type_hash.each do |m,cls|
    define_method("#{m}?") { bet_type == cls }
  end
  def no_bet_type?
    !bet_type
  end
  def team_line?
    spread? or ml?
  end
  %w(spread ml ou).each do |m|
    define_method("#{m}?") { bet_type == klass.send(m.upcase) }
  end
  module ClassMethods
    SPREAD = 'SpreadLine'
    ML = 'MoneyLine'
    OU = 'OverUnderLine'
    fattr(:bet_type_map) do
      res = Hash.new { |h,k| raise "no bet type for #{k}" }
      %w(spread spreadline).each { |x| res[x] = SPREAD }
      %w(moneyline ml).each { |x| res[x] = ML }
      %w(overunder ou over_under overunderline).each { |x| res[x] = OU }
      res
    end
    def get_bet_type(t)
      bet_type_map[t.to_s.downcase]
    end
    LineTypes.line_type_hash.each do |m,cls|
      define_method(m.to_s.upcase) { cls }
    end
  end
end

module LineResult
  def win?
    result == :win
  end
  def loss?
    result == :loss
  end
  def push?
    result == :push
  end
  def unplayed?
    result == :unplayed
  end
end

class Line < ActiveRecord::Base
  SPREAD = 'SpreadLine'
  ML = 'MoneyLine'
  OU = 'OverUnderLine'
  include LineTypes
  extend LineTypes::ClassMethods
  include LineSingleBet
  include LineResult
  after_save { |x| x.save_single_bet! }
  before_save { |x| x.effective_dt ||= Time.now }
  belongs_to :game
  belongs_to :site
  has_many :bets
  belongs_to :team_obj, :class_name => 'Team', :foreign_key => 'team_id'
  has_many :line_set_memberships
  has_many :line_sets, :through => :line_set_memberships
  has_one :book_line_set, :through => :line_set_memberships
  has_one :spread_line_set, :through => :line_set_memberships
  has_one :bet_type_line_set, :through => :line_set_memberships
  validates_presence_of :odds
  validates_presence_of :site
  validates_presence_of :game
  named_scope :active, lambda { {:conditions => ["expire_dt is null",Time.now]} }
  after_save { |x| find(x.id).setup_line_sets }
  after_create { |x| find(x.id).setup_line_sets; find(x.id).book_line_set.mark_active! }
  before_save { |x| x.set_bet_type! }
  has_many :consensus, :class_name => 'LineConsensus'
  set_inheritance_column 'bet_type'
  after_save { |x| CacheManager.new.expire_line!(x) }
  #include BetSummary
  def set_bet_type!
    dbg "set_bet_type #{bet_type} #{calc_bet_type}"
    self.bet_type ||= calc_bet_type
  end
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
    return nil unless game.correct_spread
    Gambling::Wager.new(home_favored,game.correct_spread*-1,ha,odds,game)
  end
  def wagers
    return [] unless game.sport.abbr == 'NFL' or game.sport.abbr == 'CFB'
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
  def played?
    game.played?
  end
  def result
    return :unplayed unless played?
    margin = actual_margin - spread
    return :win if margin > 0
    return :loss if margin < 0
    return :push
  rescue => exp
    puts exp
    return :error
  end
  def commision
    return 0 unless site.commision > 0
    return 0.01 if game.sport.abbr == 'MLB'
    0.02
  end
  def win_result_factor
    1*odds*(1-commision)
  end
  def result_factor
    h = {:unplayed => 0, :push => 0, :win => win_result_factor, :loss => -1}
    h[result]
  end
  def possible_teams
    game ? sub_possible_teams : Team.all
  end
  def sub_possible_teams
    game.teams + Team.ou_teams
  end
  def self.find_or_create_from_hash(h)
    LineCreator.new(h).run!
  end
  def calc_bet_type
    return klass.OU if team_obj and team_obj.over_under?
    case spread.to_closest_spread
      when 0: klass.ML
      else klass.SPREAD
    end
  end
  def line_set_hash
    res = {:game_id => game_id, :site_id => site_id, :bet_type => bet_type||calc_bet_type, :team_id => team_id}
    res[:spread] = spread.to_closest_spread unless site.changes_spread? 
    res
  end
  def setup_line_set(assoc_name)
    LineSet
    send(assoc_name).tap { |x| return x if x }
    set_class = klass.reflections[assoc_name].klass
    h = set_class.get_key(self)
    obj = set_class.find(:first, :conditions => h) || set_class.new(h).tap(&:save!)
    LineSetMembership.new(:line_set_id => obj.id, :line_id => self.id).save!
  end
  def setup_line_sets
    [:book_line_set,:spread_line_set,:bet_type_line_set].each { |x| setup_line_set(x) }
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
  def pretty_spread
    spread
  end
  def spread
    read_attribute(:spread) ? read_attribute(:spread).to_closest_spread : read_attribute(:spread)
  end
  def pretty_spread
    spread
  end
  def pretty_spread=(x)
    self.spread = x
  end
  def <=>(x)
    game <=> x.game
  end
  def correct_spread
    nil
  end
  def bet_requests(mb=nil)
    mb ||= Matchbook.new('CB')
    mb.bet_requests(game.matchbook_event_id,matchbook_market_id).select { |x| x.runner_id.to_s == matchbook_runner_id.to_s }
  end
end

module MakeBets
  def make_bet(ops)
    ops[:odds] = ops[:odds].to_s[1..-1] if ops[:odds].to_s =~ /^\+/
    ops[:market_id] = matchbook_market_id
    ops[:runner_id] = matchbook_runner_id
    ops[:runner_name] = matchbook_runner_name
    mb = ops[:mb] || Matchbook.new('CB')
    mb.make_offer(ops)
  end
end
Line.send(:include,MakeBets)

class TeamLine < Line
  def pretty_spread
    spread ? spread * -1 : spread
  end
  def pretty_spread=(x)
    self.spread = (x ? x.to_f * -1 : x)
  end
  def sub_possible_teams
    game.teams
  end
end

class SpreadLine < TeamLine
  def correct_spread
    res = game.correct_spread
    return res unless res
    res *= -1.0 unless team_id == game.home_team_id
    res
  end
end

class MoneyLine < TeamLine
end

class OverUnderLine < Line
  def wagers
    []
  end
  def spr
    spread
  end
  def sub_possible_teams
    game.teams + Team.ou_teams
  end
  def actual_margin
    game.home_score + game.away_score
  end
  def result
    return :unplayed unless played?
    margin = actual_margin - spread
    margin *= -1 if team_obj.city == 'Under'
    return :win if margin > 0
    return :loss if margin < 0
    return :push
  rescue => exp
    puts exp
    return :error
  end
end
