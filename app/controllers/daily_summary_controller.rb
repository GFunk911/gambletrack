class DailySummaryController < ApplicationController
  def index
    @games = games
  end
  def market_status
    @team = Team.find(params[:team])
    @game = Game.find(params[:id])
    render :text => @game.market_summary_str(@team).gsub(/\n/,"<br>\n"), :layout => false
  end

  private
  def games
    Game.on_day(Time.now).sort_by { |x| x.event_dt }[0..0].map { |x| GameSummary.new(x) }
  end
end
