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
  def self.current_period
    find(:first, :conditions => ["start_dt < ? and ? < end_dt",Time.now,Time.now])
  end
  def self.prev_periods
    find(:all, :conditions => ["end_dt < ?",Time.now])
  end
  def self.future_periods
    find(:all, :conditions => ["start_dt > ?",Time.now])
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
end
