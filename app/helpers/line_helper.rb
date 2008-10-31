module LineHelper
  def first_of_bet_type?(l)
    res = ($bet_type_track != l.bet_type)
    dbg "fobt #{$bet_type_track} #{l.bet_type} #{res}"
    $bet_type_track = l.bet_type
    res
  end
  def game_status(line)
    d = @divs.find { |e| e.game == line.game }
    #File.append("#{RAILS_ROOT}/debug.log",d.inspect + "\n" + @divs.size.to_s)
    d.andand.to_s_status
  end
end
