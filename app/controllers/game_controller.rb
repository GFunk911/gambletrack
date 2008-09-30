class GameController < ApplicationController
  def show
    @game = Game.find(params[:id])
    render :partial => 'form', :object => @game
  end
  def update
    puts "GameController#update"
    @game = Game.find(params[:id])
    if @game.update_attributes(params[:game])
      flash[:notice] = "Updated Game"
    else
      raise 'failed'
    end
  end
end
