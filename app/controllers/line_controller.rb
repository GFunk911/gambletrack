class LineController < ApplicationController
  cache_sweeper :game_sweeper
  def show
    $bet_type_track = 938457
    dbg "\nLine#show"
    @obj = get_poly_obj(params)
    render :partial => 'game/lines', :object => @obj, :layout => false, :locals => {:active => params[:active]}
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
  def convert_to_percent(x)
    return x unless x
    return x unless x.to_f > 0.999
    x.to_f / 100.0
  end
  def modified_params(ps=params[:search])
    res = Marshal.load(Marshal.dump(ps))
    
    if res
      res[:conditions][:game][:event_dt_lt] = parse_date(res[:conditions][:game][:event_dt_lt])
      res[:conditions][:game][:event_dt_gt] = parse_date(res[:conditions][:game][:event_dt_gt])
      
      if res[:conditions][:game][:event_dt_lt] and res[:conditions][:game][:event_dt_lt].hour != 23
        res[:conditions][:game][:event_dt_lt] = res[:conditions][:game][:event_dt_lt] + (0.999).days.to_f
        #params[:search][:conditions][:event_dt_lt] = Time.parsedate(params[:search][:conditions]['event_dt_gt']) + 1.days
      end
      
      res[:conditions][:cached_bet_percent_lt] = convert_to_percent(res[:conditions][:cached_bet_percent_lt])
      res[:conditions][:cached_bet_percent_gt] = convert_to_percent(res[:conditions][:cached_bet_percent_gt])
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
    LineSet
    10.times { puts params.inspect }
    File.append("#{RAILS_ROOT}/debug.log",params.inspect+"\n")
    #File.append("#{RAILS_ROOT}/debug.log",params[:search]['per_page'].inspect+"\n")
    if params[:search_id]
      @search_object = Search.find(params[:search_id])
      @search = BetTypeLineSet.new_search(modified_params(@search_object.search_params))
    elsif params[:search] and params[:search]['id']
        @search_object = Search.find(params[:search]['id'])
        @search = BetTypeLineSet.new_search(modified_params(@search_object.search_params))
    elsif params[:search]
      @search_object = Search.new(params[:search]['search'])
      @search_object.search_class_name = 'BetTypeLineSet'
      @search_object.search_params = modified_params
      @search_object.save! if @search_object.do_save
      @search = BetTypeLineSet.new_search(modified_params)
    else
      @search_object = Search.new
      @search_object.search_class_name = 'BetTypeLineSet'
      @search = BetTypeLineSet.new_search
      #@search.per_page = 100
    end

    
    #@search.event_dt_lt = @search.event_dt_gt + 1.days
    @games, @games_count = @search.all, @search.count
    @divs = (@search_object.show_scores.to_i == 1) ? get_espn_games : []
    #@divs = ESPNScores.new.game_divs.select { |x| @games.include?(x.game) }
    #render :partial => 'game/index'
  end
  def get_espn_games_2
    @espn_hash = Hash.new { |h,k| h[k] = ESPNScores.new(k) }
    @games.map do |g|
      abbr = g.sport.abbr.gsub(/cfb/i,"ncf")
      @espn_hash[abbr].game_divs.find { |d| d.game == g }
    end.select { |x| x }
  end
  def get_espn_games
    %w(NBA NHL NCF).map { |x| ESPNScores.new(x).game_divs }.flatten
  end
end
