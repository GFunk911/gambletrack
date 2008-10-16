class Game < ActiveRecord::Base
  include PO::GameModule
  extend PO::GameModule::ClassMethods
  include BetSummary

  has_many :lines, :order => ["bet_type,team_id,line_set_id,created_at desc"], :attributes => true, :discard_if => lambda { |x| x.odds.blank? }
  has_many :line_sets, :attributes => true, :discard_if => lambda { |x| x.odds.blank? }
  belongs_to :home_team_obj, :class_name => 'Team', :foreign_key => 'home_team_id'
  belongs_to :away_team_obj, :class_name => 'Team', :foreign_key => 'away_team_id'
  include WagerModule
  belongs_to :sport
  def home_team
    home_team_obj.short_name
  end
  def away_team
    away_team_obj.short_name
  end
  def bets
    lines.map { |x| x.bets }.flatten
  end
  belongs_to :period
  def self.load_nfl_games
    ps = Period.find(:all)
    games.each do |g|
      res = new
      puts g.home_team
      res.home_team = g.home_team.to_s
      res.away_team = g.away_team.to_s
      res.event_dt = Time.local(2008,9,7,13) + (g.week - 1)*7.days
      res.period = ps.select { |x| x.start_dt < res.event_dt and x.end_dt > res.event_dt }.first
      res.save!
    end
  end
  def self.update_nfl_games
    gs = find(:all).group_by { |x| [x.home_team,x.away_team,x.period.week] }
    games.select { |x| x.played? }.each do |nfl|
      g = gs[[nfl.home_team.to_s,nfl.away_team.to_s,nfl.week]].first
      g.home_score = nfl.home_score
      g.away_score = nfl.away_score
      g.save!
    end
  end
  named_scope :week, lambda { |w| {:include => :lines, :conditions => ['event_dt >= ? and event_dt <= ?']+dates_for_week(w)}}
  #named_scope :teams, lambda { |a,h| {:conditions => ['home_team = ? and away_team = ?',h,a]} }
  named_scope(:upcoming, lambda do |*args|
    days = args.first || 7
    {:conditions => ["event_dt > ? and event_dt < ?",Time.my_current,Time.my_current+days.days]}
  end)
  named_scope(:by_away, lambda do |t|
    {:conditions => ["team_names.search_string like ?","%#{t.downcase}%"], 
     :include => {:away_team_obj => :names}}
  end)
  named_scope(:by_home, lambda do |t|
    {:conditions => ["team_names.search_string like ?","%#{t.downcase}%"], 
     :include => {:home_team_obj => :names}}
  end)
  named_scope(:by_team_names, lambda do |a,h|
    {:conditions => ["team_names.search_string like ? and names_teams.search_string like ?","%#{a.downcase}%","%#{h.downcase}%"],
     :include => {:away_team_obj => :names, :home_team_obj => :names}}
  end)
  named_scope(:since, lambda do |t|
    {:conditions => ["event_dt > ?",t]}
  end)

  def self.dates_for_week(i)
    start = Time.local(2008,9,4,13) + (i - 1)*7.days
    end_dt = start + 5.days
    [start,end_dt]
  end

  def week
    ((event_dt - Time.local(2008,9,7,13)) / 7.days).to_i + 1
  end
  
  def childrenx
    lines
  end
  def desc
    "#{away_team}@#{home_team}"
  end
  def teams
    [away_team_obj,home_team_obj]
  end

  def wager_for_linex(ln)
    #bet_type = (ln['TEASER'] ? 'teaser' : 'unknown')
    Gambling::Wager.new(ln.home_favored,correct_spread,ln.ha,ln.odds,self)
  end
  def wagersx
    lines.map do |ln|
      wager_for_line(ln)
    end.flatten.sort_by { |x| x.kelly_perc }.reverse
  end
  def team_margin(t)
    return nil unless played?
    (t.to_s == home_team) ? home_score-away_score : away_score - home_score
  end
  def played?
    home_score and away_score
  end
  def summary_groupings
    [lines_grouped_by_line,lines_grouped_by_effective_line]
  end
  def <=>(x)
    event_dt <=> x.event_dt
  end
  def cfb_correct_spread
    a = away_team_obj.cfb_sagarin
    h = home_team_obj.cfb_sagarin
    return nil unless a and h
    (h - a + 3.0).to_closest_spread
  end
  def inner_correct_spread
    return nfl_correct_spread if sport.abbr == 'NFL'
    return cfb_correct_spread if sport.abbr == 'CFB'
    nil
  end
  def correct_spread
    inner_correct_spread ? inner_correct_spread*-1 : nil
  end
  fattr(:current_spread) do
    lines.find(:first, :conditions => ["expire_dt is null and team_id = ? and bet_type = ?",home_team_id,'SpreadLine'], :order => "created_at desc").tap { |x| return nil unless x }.spread * -1
  end
  def spread_gap
    correct_spread - current_spread
  end
  def spread_gap?
    correct_spread and current_spread
  end
  def game_line_fields
    ["#{away_team}@#{home_team}",current_spread,correct_spread,spread_gap,away_team_obj.rating,home_team_obj.rating]
  end
end

class FlexMigration < ActiveRecord::Migration
  class << self
    attr_accessor :up_blk
  end
  def self.run!(&b)
    self.up_blk = b
    FlexMigration.migrate(:up)
  end
  def self.up
    instance_eval(&up_blk)
  end
end

