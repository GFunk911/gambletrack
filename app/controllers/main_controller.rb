class MainController < ApplicationController
  cache_sweeper :game_sweeper
  caches_page :index
  def index
  end
  def show
    raise "can't show" unless %w(load_matchbook load_bets test exp).include?(params[:id])
    if params[:id] == 'load_matchbook'
      LinesDataload.new.load_all!
      flash[:notice] = "Loaded lines from Matchbook"
      redirect_to :controller => 'main', :action => 'index'
    elsif params[:id] == 'load_bets'
      LinesDataload.new.load_bets!
      flash[:notice] = "Loaded bets from Matchbook"
      redirect_to :controller => 'main', :action => 'index'
    elsif params[:id] == 'exp'
      expire_fragment(:controller => 'main', :action => 'show', :id => 2)
      puts "Expired Fragment"
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
