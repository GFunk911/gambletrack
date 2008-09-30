class Spread
  attr_accessor :fb
  def initialize(fb)
    @fb = fb ? fb.to_closest_spread : fb
  end
  def to_s
    if fb > 0
      "-#{fb}"
    else
      "+#{fb}"
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
end

class Line < ActiveRecord::Base
  include LineSingleBet
  after_save { |x| x.save_single_bet! }
  belongs_to :game
  belongs_to :site
  has_many :bets
  validates_presence_of :odds
  validates_presence_of :site
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
    "#{team} #{spr} #{odds} #{wager.kelly_perc}"
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
  def children
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
end




