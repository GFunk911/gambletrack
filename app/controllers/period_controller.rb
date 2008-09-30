class PeriodController < ApplicationController
  def show
    @games = Game.week(params[:id].to_i)
  end
end
