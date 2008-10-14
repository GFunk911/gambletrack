class Sport < ActiveRecord::Base
  has_many :games
  has_many :teams
  has_many :names, :through => :teams
  has_many :periods, :include => :games
  def find_team(t)
    names.matching(t).tap { |x| raise "found #{x.size} matching teams for #{t}.  #{x.inspect}" if x.size > 1; return nil if x.empty? }.first.team
  end
  def current_period
    periods.current_and_future_periods.first
  end
  def desc
    name
  end
  def children
    Period
    Periods.new(periods).children
  end
end

class Sports
  def desc
    'Sports'
  end
  def children
    Sport.all
  end
end
