class Periods
  attr_accessor :periods
  def initialize(ps)
    @periods = ps
  end
  def desc
    "Weeks"
  end
  def children
    a = PeriodSet.new("Prev Weeks",periods.prev_periods)
    b = PeriodSet.new("Future Weeks",periods.future_periods)
    [a,periods.current_period_array.first,b]
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
end
