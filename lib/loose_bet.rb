class LooseBet
  class << self
    fattr(:all) { [] }
    def between(start_dt,end_dt)
      all.select { |x| x.dt > start_dt and x.dt < end_dt }
    end
  end
  attr_accessor :sport, :dt, :win_amount, :note
  def initialize(sport,dt,win_amount,note)
    @sport = Sport.find_by_abbr(sport)
    dt = Time.parsedate(dt)
    @dt = Time.local(dt.year,dt.month,dt.day,12)
    @win_amount = win_amount
    @note = note
  end
  def wagered_amount
    win_amount.abs
  end
end

def loose_bet(*args)
  LooseBet.all << LooseBet.new(*args)
end

loose_bet :CFB, '10/25/2008',1500,'La Tech/UConn Teaser'
loose_bet :NHL, '10/22/2008',477.76,"Day's Hockey"
