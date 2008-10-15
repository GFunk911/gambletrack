class Sport < ActiveRecord::Base
  has_many :games
  has_many :teams
  has_many :names, :through => :teams
  has_many :periods, :include => :games
  has_many :lines, :through => :games
  include BetSummary
  include LineSummary
  include WagerModule
  def find_team(t)
    if Team.over_under?(t)
      Team.find_by_city(t)
    else
      names.matching(t).tap { |x| raise "found #{x.size} matching teams for #{t}.  #{x.inspect}" if x.size > 1; return nil if x.empty? }.first.team
    end
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
  def line_summary_children
    effective_lines
  end
end

class Sports
  include WagerModule
  include BetSummary
  def desc
    'Sports'
  end
  fattr(:children) do
    Sport.all
  end
  def summary_groupings
    [lines_grouped_by_line,lines_grouped_by_sport]
  end
  def lines
    children.map { |x| x.lines }.flatten
  end
  def bet_children
    lines
  end
  def lines_grouped_by_sport
    GroupedLines.new(children,%w(Sport),%w(num_wins num_losses num_pushes desired_amount wagered_amount win_amount roi)) { |x| x.name }
  end
end
