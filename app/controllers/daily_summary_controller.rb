class DailySummaryController < ApplicationController
  def index
    @games = games
  end
  def market_status
    @team = Team.find(params[:team])
    @game = Game.find(params[:id])
    render :partial => 'market_status', :layout => false, :locals => {:game => @game, :team => @team}
  end

  private
  def games
    Game.on_day(Time.now).map { |x| GameSummary.new(x) }.sort_by { |x| [x.bracket||4,x.event_dt] }
  end
end
