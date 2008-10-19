class MainController < ApplicationController
  cache_sweeper :game_sweeper
  caches_page :index
  def index
  end
  def show
    raise "can't show" unless params[:id] == 'load_matchbook' or params[:id] == 'test'
    if params[:id] == 'load_matchbook'
      LinesDataload.new.load_all!
      flash[:notice] = "Loaded lines from Matchbook"
      redirect_to :controller => 'main', :action => 'index'
    else
      g = Game.find(340)
      t = g.sport.teams[rand(28)]
      5.times { puts t.city }
      g.home_team_obj = t
      g.save!
      Game.new.save!
      redirect_to :controller => 'main', :action => 'index'
    end
  end
end
