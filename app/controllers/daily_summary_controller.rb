class GameSummary
  attr_accessor :game
  def initialize(g)
    @game = g
  end
  def method_missing(sym,*args,&b)
    game.send(sym,*args,&b)
  end
  def spread_for_contrarian(l)
    return nil unless l
    line_for_contrarian(l).spread * -1
  end
  def line_for_contrarian(l)
    t = (anti_public_team ? anti_public_team : home_team_obj)
    return l if l.team_obj == t
    res = l.clone
    res.team_obj = anti_public_team
    res.spread = res.spread * -1
    res
  end
  fattr(:pinny) do
    Site.find_by_name('Pinnacle')
  end
  fattr(:pinny_lines) do
    lines.select { |l| l.site_id == pinny.id }.sort_by { |x| x.created_at }
  end
  def current_spread
    spread_for_contrarian(pinny_lines.to_a[-1])
  end
  def open_spread
    spread_for_contrarian(pinny_lines.to_a[0])
  end
  def time
    event_dt.strftime("%I:%M %p")
  end
  fattr(:cons) do
    consensus.to_a[-1]
  end
  fattr(:line_sets) do
    game.mb_spread_line_sets(anti_public_team)
  end
  fattr(:anti_public_team) do
    if cons
      other = [home_team_obj,away_team_obj].reject { |x| x == cons.line.team_obj }.first
      (cons.bet_percent < 0.5) ? cons.line.team_obj : other
    else
      nil
    end
  end
  def anti_public_percent
    return nil unless cons
    res = (cons.bet_percent < 0.5) ? cons.bet_percent : (1.0 - cons.bet_percent)
    res.to_perc
  end
  def id
    game.id
  end
end

class DailySummaryController < ApplicationController
  def index
    @games = games
  end
  def market_status
    @team = Team.find(params[:team])
    @game = Game.find(params[:id])
  end

  private
  def games
    Game.on_day(Time.now).sort_by { |x| x.event_dt }.map { |x| GameSummary.new(x) }
  end
end
