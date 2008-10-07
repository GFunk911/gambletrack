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
  include BetSummary
  include WagerModule
  def self.current_period
    res = find(:first, :conditions => ["start_dt < ? and ? < end_dt",Time.now,Time.now])
    res ||= find(:first, :conditions => ["start_dt > ?",Time.now], :order => "start_dt asc")
    res
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
  def week
    name.split[-1].to_i
  end
end
