class MainController < ApplicationController
  def index
  end
  def show
    raise "can't show" unless params[:id] == 'load_matchbook'
    LinesDataload.new.load_all!
    flash[:notice] = "Loaded lines from Matchbook"
    redirect_to :controller => 'main', :action => 'index'
  end
end
