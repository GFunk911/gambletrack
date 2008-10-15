module LineHelper
  def first_of_bet_type?(l)
    res = ($bet_type_track != l.bet_type)
    dbg "fobt #{$bet_type_track} #{l.bet_type} #{res}"
    $bet_type_track = l.bet_type
    res
  end
end
