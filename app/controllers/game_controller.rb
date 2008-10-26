class GameController < ApplicationController
  #caches_page :show
  #cache_sweeper :game_sweeper
  def get_dt
    str = params[:date]
    str += Time.now.year.to_s if str.length == 4
    raise "can't get date for #{str}" unless str.length == 8
    Time.local(str[4...8].to_i,str[0...2].to_i,str[2...4].to_i).tap_to_s('Returning')
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
  def effective_today
    (Time.now.hour >= 8) ? Time.now.start_of_day  : Time.now.start_of_day - 1.days
  end
  def parse_date(str)
    puts "parse_date #{str}"
    return str unless str
    return str if str.is_a?(Time)
    return Time.parsedate(str) unless str =~ /today/i
    mod = str.gsub(/today/i,"").strip
    (effective_today + mod.to_i.days).tap_to_s('parse_date')
  end
  def modified_params(ps=params[:search])
    res = Marshal.load(Marshal.dump(ps))
    
    if res
      res[:conditions][:event_dt_lt] = parse_date(res[:conditions][:event_dt_lt])
      res[:conditions][:event_dt_gt] = parse_date(res[:conditions][:event_dt_gt])
      
      if res[:conditions][:event_dt_lt] and res[:conditions][:event_dt_lt].hour != 23
        res[:conditions][:event_dt_lt] = res[:conditions][:event_dt_lt] + (0.999).days.to_f
        #params[:search][:conditions][:event_dt_lt] = Time.parsedate(params[:search][:conditions]['event_dt_gt']) + 1.days
      end
      res.delete('search')
    end
    puts "Res: " + res.inspect
    res
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
    
    10.times { puts params.inspect }
    if params[:search_id]
      @search_object = Search.find(params[:search_id])
      @search = Game.new_search(modified_params(@search_object.search_params))
    elsif params[:search]
      @search_object = Search.new(params[:search]['search'])
      @search_object.search_params = modified_params
      @search_object.save! if @search_object.do_save
      @search = Game.new_search(modified_params)
    else
      @search_object = Search.new
      @search = Game.new_search
    end

    
    #@search.event_dt_lt = @search.event_dt_gt + 1.days
    @games, @games_count = @search.all, @search.count
    @espn_hash = Hash.new { |h,k| h[k] = ESPNScores.new(k) }
    @divs = @games.map do |g|
      abbr = g.sport.abbr.gsub(/cfb/i,"ncf")
      @espn_hash[abbr].game_divs.find { |d| d.game == g }
    end.select { |x| x }
    #@divs = ESPNScores.new.game_divs.select { |x| @games.include?(x.game) }
    #render :partial => 'game/index'
  end
end
