class GameSummary
  attr_accessor :game
  def initialize(g)
    @game = g
  end
  def method_missing(sym,*args,&b)
    game.send(sym,*args,&b)
  end
  def spread_for_home(l)
    return nil unless l
    line_for_home(l).spread * -1
  end
  def line_for_home(l)
    return l if l.team_obj == home_team_obj
    res = l.clone
    res.team_obj = home_team_obj
    res.spread = res.spread * -1
    res
  end
  def current_spread
    spread_for_home(lines.to_a[-1])
  end
  def open_spread
    spread_for_home(lines.to_a[0])
  end
  def time
    event_dt.strftime("%I:%M %p")
  end
  fattr(:cons) do
    consensus.to_a[-1]
  end
  def anti_public_team
    return nil unless cons
    other = [home_team_obj,away_team_obj].reject { |x| x == cons.line.team_obj }.first
    (cons.bet_percent < 0.5) ? cons.line.team_obj : other
  end
  def anti_public_percent
    return nil unless cons
    res = (cons.bet_percent < 0.5) ? cons.bet_percent : (1.0 - cons.bet_percent)
    res.to_perc
  end
end

class DailySummaryController < ApplicationController
  def index
    @games = Game.on_day(Time.now).sort_by { |x| x.event_dt }.map { |x| GameSummary.new(x) }
  end
end
