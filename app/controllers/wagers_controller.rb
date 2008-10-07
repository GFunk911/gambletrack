class WagersController < ApplicationController
  def show
    @obj = get_poly_obj(params)
    render :partial => 'game/wagers', :object => @obj.active_wagers, :layout => false
  end
end
