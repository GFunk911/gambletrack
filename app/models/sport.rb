class Sport < ActiveRecord::Base
  has_many :games, :order => 'event_dt asc'
  has_many :teams
  has_many :names, :through => :teams
  has_many :periods, :include => :games, :order => 'start_dt asc'
  has_many :lines, :through => :games
  has_many :rating_types
  include BetSummary
  include LineSummary
  include WagerModule
  def find_team(t)
    if Team.over_under?(t)
      Team.find_by_city(t)
    else
      [t,t.gsub(/\./,""),"#{t} U",t.gsub(/ U$/,""),t.gsub(/Northern/,'No'),t.gsub(/SW Missouri St./,'Missouri St')].uniq.each do |team|
        ts = names.matching(team).map { |x| x.team }.uniq
        raise "found #{ts.size} matching teams for #{team}.  #{ts.inspect}" if ts.size > 1;
        return ts.first if ts.size == 1
      end
      return nil
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
    Periods.new(periods.has_games.since(14.days.ago)).children
  end
  def line_summary_children
    effective_lines
  end
  def win_amount_since(t)
    games(:include => {:lines => :bets}).since(t).map { |x| x.win_amount }.sum
  end
  def lines_grouped_by_period
    GroupedLines.new(periods,%w(Period),%w(num_wins num_losses num_pushes desired_amount wagered_amount win_amount roi)) { |x| x.name }
  end
  def summary_groupings
    [lines_grouped_by_period]
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
  def win_amount_since(t)
    children.map { |x| x.win_amount_since(t) }.sum
  end
end
