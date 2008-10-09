class Periods
  def desc
    "Weeks"
  end
  def children
    a = PeriodSet.new("Prev Weeks",Period.prev_periods)
    b = PeriodSet.new("Future Weeks",Period.future_periods)
    [a,Period.current_period,b]
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
  has_many :games
  has_many :lines, :through => :games, :attributes => true, :discard_if => lambda { |x| x.odds.blank? }
  belongs_to :sport
  include BetSummary
  include WagerModule
  named_scope :current_and_future_periods, lambda { {:conditions => ["start_dt > ?",Time.now], :order => "start_dt asc"} }
  def self.current_period
    current_and_future_periods.first
  end
  def self.prev_periods
    find(:all, :conditions => ["end_dt <= ?",current_period.start_dt])
  end
  def self.future_periods
    find(:all, :conditions => ["start_dt >= ?",current_period.end_dt])
  end
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
