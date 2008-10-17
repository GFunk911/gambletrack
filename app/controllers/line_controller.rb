class LineController < ApplicationController
  cache_sweeper :game_sweeper
  def show
    $bet_type_track = 938457
    dbg "\nLine#show"
    @obj = get_poly_obj(params)
    render :partial => 'game/lines', :object => @obj, :layout => false, :locals => {:active => params[:active]}
  end
end
