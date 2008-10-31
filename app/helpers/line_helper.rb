module LineHelper
  def first_of_bet_type?(l)
    res = ($bet_type_track != l.bet_type)
    dbg "fobt #{$bet_type_track} #{l.bet_type} #{res}"
    $bet_type_track = l.bet_type
    res
  end
  def game_div(line)
    @divs.find { |e| e.game == line.game }
  end
  def game_status_text(line)
    d = game_div(line)
    #File.append("#{RAILS_ROOT}/debug.log",d.inspect + "\n" + @divs.size.to_s)
    d.andand.to_s_status
  end
  def winning_team(g)
    return g.teams[0] if g.away_score.to_i > g.home_score.to_i
    return g.teams[1] if g.away_score.to_i < g.home_score.to_i
    nil
  end
  def game_status_color(line)
    d = game_div(line)
    return nil unless d
    return nil unless winning_team(d)
    t = line.game.sport.find_team(winning_team(d))
    return 'Green' if t.id == line.team_id
    return 'Red'
  end
  def game_status2(line)
    "<font color=\"#{game_status_color(line)}\">#{game_status_text(line)}</font>"
  end
  def game_status(line)
    game_status_text(line)
  end
    
end
