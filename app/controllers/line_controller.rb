class LineController < ApplicationController
  def show
    @obj = get_poly_obj(params)
    render :partial => 'game/lines', :object => @obj, :layout => false, :locals => {:active => params[:active]}
  end
end
