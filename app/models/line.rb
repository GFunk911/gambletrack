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
    puts "line id #{self.id}"
    bets.new.tap { |x| x.save! if x.line_id }
  end
  %w(desired_amount outstanding_amount wagered_amount).each do |meth|
    writ = "#{meth}="
    define_method(meth) { single_bet.send(meth) }
    define_method(writ) { |x| single_bet.send(writ,x) }
  end
  def save_single_bet!
    puts "calling save_single_bet!"
    raise "line has no id" unless self.id
    single_bet.line_id = id
    single_bet.save!
  end
  def has_bet?
    wagered_amount > 0 or desired_amount > 0
  end
  def win_amount
    single_bet.win_amount
  end
end

class Line < ActiveRecord::Base
  include LineSingleBet
  after_save { |x| x.save_single_bet! }
  before_save { |x| x.effective_dt ||= Time.now }
  belongs_to :game
  belongs_to :site
  has_many :bets
  belongs_to :line_set
  validates_presence_of :odds
  validates_presence_of :site
  validates_presence_of :game
  named_scope :active, lambda { {:conditions => ["expire_dt is null",Time.now]} }
  before_save { |x| x.find_or_create_line_set }
  after_create { |x| x.line_set.mark_active! }
  #include BetSummary
  def save
    puts "calling Line#save"
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
    "#{team} #{spr} #{odds} #{wager.kelly_perc} #{created_at}"
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
    [wager,teaser_wager].select { |x| x }
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
      games.map { |x| [x.home_team,x.away_team] }.flatten.map { |x| x.to_s }.uniq.sort
    end
  end
  def self.find_or_create_from_hash(h)
    $hh ||= []
    $hh2 ||= []
    desc = "#{h[:away_team]}@#{h[:home_team]} #{h[:team]} #{h[:spread]} #{h[:odds]} rfd: #{Gambling::Odds.get(h[:odds]).rfd}"
    #puts desc
    pid = Period.current_period.id
    site = Site.find(:first, :conditions => ["name = ?",'Matchbook'])
    g = Game.find(:first, :conditions => ["period_id = ? and home_team = ? and away_team = ?",pid,h[:home_team],h[:away_team]]).tap { |x| raise "no game for #{desc}" unless x }
    index_match = lambda { |a,b| res = nil; (0..3).each { |i| res ||= i.to_s if a[i] != b[i] }; res || 'equal' }
    match_arr = [h[:spread].to_closest_spread,Gambling::Odds.get(h[:odds]).rfd.to_f,h[:team],site.id]
    match_arr += match_arr.map { |x| x.class }
    game_arr = lambda { |x| [x.spread.to_closest_spread,x.return_from_dollar.to_f,x.team,x.site_id] + [x.spread.to_closest_spread,x.return_from_dollar,x.team,x.site_id].map { |x| x.class } }
    $hh2 << match_arr
    line = g.lines.select { |x| x.spread.to_closest_spread == h[:spread].to_closest_spread and x.return_from_dollar.round_dec(3) == Gambling::Odds.get(h[:odds]).rfd.round_dec(3) and x.team == h[:team] and x.site_id == site.id }.first
    if line
      puts "found #{desc}"
    else
      puts "creating #{desc}"
      #g.lines.each { |x| puts x.inspect }
      line = g.lines.new(:team => h[:team], :return_from_dollar => Gambling::Odds.get(h[:odds]).rfd.to_f, :spread => h[:spread], :site => site)
      line.save!
    end
    line
  end
  def find_or_create_line_set
    return line_set if line_set
    set = LineSet.find(:first, :conditions => ["site_id = ? and game_id = ? and spread = ? and team = ?",site_id,game_id,spread,team])
    set ||= LineSet.new(:game_id => game_id, :site_id => site_id, :spread => spread.to_closest_spread, :team => team).tap { |x| x.save! }
    self.line_set = set
    set
  end
  def self.reset_lineset!
    LineSet.find(:all).each { |x| x.destroy }
    find(:all).each { |x| x.line_set = nil; x.save! }
    LineSet.find(:all).each { |x| x.mark_active! }
  end
  def active?
    !expire_dt
  end
  def expired?
    !active?
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
end




