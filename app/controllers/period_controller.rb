class PeriodController < ApplicationController
  def show
    @period = Period.find(params[:id])
    @games = @period.games
  end
  def update
    @period = Period.find(params[:id])
    @games = @period.games
    puts "PeriodController#update"
    if @period.update_attributes(params[:period])
      flash[:notice] = "Updated Period"
    else
      raise 'failed'
    end
  end
end
