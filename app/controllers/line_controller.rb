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
  def modified_params(ps=params[:search])
    res = Marshal.load(Marshal.dump(ps))
    
    if res
      res[:conditions][:game][:event_dt_lt] = parse_date(res[:conditions][:game][:event_dt_lt])
      res[:conditions][:game][:event_dt_gt] = parse_date(res[:conditions][:game][:event_dt_gt])
      
      if res[:conditions][:game][:event_dt_lt] and res[:conditions][:game][:event_dt_lt].hour != 23
        res[:conditions][:game][:event_dt_lt] = res[:conditions][:game][:event_dt_lt] + (0.999).days.to_f
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
    LineSet
    10.times { puts params.inspect }
    if params[:search_id]
      @search_object = Search.find(params[:search_id])
      @search = BetTypeLineSet.new_search(modified_params(@search_object.search_params))
    elsif params[:search] and params[:search]['id']
        @search_object = Search.find(params[:search]['id'])
        @search = BetTypeLineSet.new_search(modified_params(@search_object.search_params))
    elsif params[:search]
      @search_object = Search.new(params[:search]['search'])
      @search_object.search_params = modified_params
      @search_object.save! if @search_object.do_save
      @search = BetTypeLineSet.new_search(modified_params)
    else
      @search_object = Search.new
      @search = BetTypeLineSet.new_search
    end

    
    #@search.event_dt_lt = @search.event_dt_gt + 1.days
    @games, @games_count = @search.all, @search.count
    @divs = []
    #@divs = (@search_object.show_scores.to_i == 1) ? get_espn_divs : []
    #@divs = ESPNScores.new.game_divs.select { |x| @games.include?(x.game) }
    #render :partial => 'game/index'
  end
end
