class Periods
  attr_accessor :periods
  def initialize(ps)
    @periods = ps
  end
  def desc
    periods.first.week? ? "Weeks" : "Days"
  end
  fattr(:current_period) { periods.current_period_array.first }
  def children
    a = PeriodSet.new("Prev #{desc}",periods.prev_periods)
    b = PeriodSet.new("Future #{desc}",periods.future_periods)
    [a,periods.current_period,b].reject { |x| x.is_a?(PeriodSet) and x.children.empty? }.select { |x| x }
  end
end

class PeriodSet
  attr_accessor :desc, :children
  def initialize(name,periods)
    @desc = name
    @children = periods
  end
  def current?
    children.any? { |x| x.current? }
  end
end

class Period < ActiveRecord::Base
  has_many :games, :include => [:home_team_obj,:away_team_obj]
  has_many :lines, :through => :games, :attributes => true, :discard_if => lambda { |x| x.odds.blank? }
  belongs_to :sport
  include BetSummary
  include WagerModule
  include LineSummary
  named_scope(:has_games, lambda do
    {:conditions => "periods.id in (select period_id from games)"}
  end)
  named_scope(:all_containing, lambda do |t|
    {:conditions => ["start_dt < ? and end_dt > ?",t,t]}
  end)
  named_scope :current_and_future_periods, lambda { {:conditions => ["end_dt > ?",Time.now], :order => "start_dt asc"} }
  def self.current_period
    current_period_array.first
  end
  named_scope(:current_period_array, lambda do
    {:conditions => ["start_dt < ? and ? < end_dt",Time.now,Time.now]}
  end)
  named_scope(:prev_periods, lambda do
    {:conditions => ["end_dt < ?",Time.now]}
  end)
  named_scope(:future_periods, lambda do
    {:conditions => ["start_dt > ?",Time.now]}
  end)
  named_scope(:in_year, lambda do |y|
    {:conditions => ["start_dt > ? and start_dt < ?",Time.local(y,1,1),Time.local(y,12,30)]}
  end)
  def desc
    self.name
  end
  def children
    games
  end
  def current?
    (start_dt..end_dt).include?(Time.now)
  end
  def week
    name.split[-1].to_i
  end
  def lines_grouped_by_game
    GroupedLines.new(games,%w(Game),%w(desired_amount wagered_amount win_amount)) { |x| x.desc }
  end
  def summary_groupings
    [lines_grouped_by_line,lines_grouped_by_effective_line,lines_grouped_by_game]
  end
  def line_summary_children
    effective_lines
  end
  def <=>(x)
    start_dt <=> x.start_dt
  end
  def week?
    (600000..620000).include?((end_dt - start_dt).to_i)
  end
end
