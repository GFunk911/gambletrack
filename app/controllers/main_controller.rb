class MainController < ApplicationController
  cache_sweeper :game_sweeper
  caches_page :index
  def index
  end
  def show
    LineSet
    raise "can't show" unless %w(load_matchbook load_bets test exp load_scores load_consensus).include?(params[:id])
    if params[:id] == 'load_matchbook'
      LinesDataload.new.load_all!
      flash[:notice] = "Loaded lines from Matchbook"
      #redirect_to :controller => 'main', :action => 'index'
    elsif params[:id] == 'load_bets'
      LinesDataload.new.load_matchbook_bets!
      flash[:notice] = "Loaded bets from Matchbook"
      #redirect_to :controller => 'main', :action => 'index'
    elsif params[:id] == 'load_consensus'
      ConsensusLoad.new.load!
      flash[:notice] = "Loaded Consensus"
    elsif params[:id] == 'exp'
      expire_fragment(:controller => 'main', :action => 'show', :id => 2)
      puts "Expired Fragment"
    elsif params[:id] == 'load_scores'
      Line
      SIScores.new.hashes.each do |h|
        GameUpdater.new(h).run!
      end
    else
      g = Game.find(340)
      t = g.sport.teams[rand(28)]
      5.times { puts t.city }
      g.home_team_obj = t
      g.save!
      Game.new.save!
      #redirect_to :controller => 'main', :action => 'index'
    end
  end
end
