class Time
  def start_of_day
    klass.local(year,month,day)
  end
end

class Bankroll
  attr_accessor :start_dt, :end_dt, :start_amount
  def initialize(ops)
    @start_dt = ops[:start_dt]
    @end_dt = ops[:end_dt] || Time.my_current.start_of_day
    @start_amount = ops[:start_amount]
  end
  fattr(:bets) do
    Game.has_wager.between(start_dt,end_dt).map { |x| x.bets }.flatten
  end
  fattr(:change) do
    bets.map { |x| x.win_amount }.sum
  end
  def current
    change + start_amount
  end
end

