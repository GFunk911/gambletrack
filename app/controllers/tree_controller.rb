class TreeController < ApplicationController
  def index
    Game.new
    render :partial => 'tree', :object => Week.new(3), :layout => true
  end
end
