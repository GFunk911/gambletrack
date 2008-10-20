class GameController < ApplicationController
  #caches_page :show
  #cache_sweeper :game_sweeper
  def get_dt
    str = params[:date]
    str += Time.now.year.to_s if str.length == 4
    raise "can't get date for #{str}" unless str.length == 8
    Time.local(str[4...8].to_i,str[0...2].to_i,str[2...4].to_i).tap { |x| puts "returning #{x}" }
  end
  def get_game
    return Game.find(params[:id]) if params[:id]
    if params[:home]
      res = Game.by_team_names(params[:away],params[:home]).on_day(get_dt).first 
      raise "no game found matching #{params[:away]}@#{params[:home]} on #{get_dt}" unless res
      return res
    end
    raise "no game"
  end
  def show
    @game = get_game
    render :partial => 'form', :object => @game, :layout => true
  end
  def update
    puts "GameController#update"
    @game = Game.find(params[:id])
    if @game.update_attributes(params[:game])
      flash[:notice] = "Updated Game"
    else
      raise 'failed'
    end
    redirect_to :action => 'show'
  end
  def index
    #puts params[:search]['event_dt_gt']
    #if params[:search]
    #  if params[:search][:conditions][:home_score_gt] == '0'
    #    params[:search][:conditions][:home_score_gt] = nil
    #  else
    #    params[:search][:conditions][:home_score_gt] = 0
    #  puts params[:search][:conditions][:home_score_gt].to_s + " " + params[:search][:conditions][:home_score_gt].class.to_s
    #end
    if params[:search] and params[:search][:conditions][:event_dt_lt] and Time.parsedate(params[:search][:conditions][:event_dt_lt]).hour != 23
      params[:search][:conditions][:event_dt_lt] = Time.parsedate(params[:search][:conditions][:event_dt_lt]) + (0.999).days.to_f
      #params[:search][:conditions][:event_dt_lt] = Time.parsedate(params[:search][:conditions]['event_dt_gt']) + 1.days
    end
    @search = Game.new_search(params[:search])
    
    #@search.event_dt_lt = @search.event_dt_gt + 1.days
    @games, @games_count = @search.all, @search.count
    #render :partial => 'game/index'
  end
end
