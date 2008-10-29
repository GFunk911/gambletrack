class Currency
  attr_accessor :num
  def initialize(num)
    @num = num
  end
  def sign
    (num < 0) ? "-" : ""
  end
  def to_s
    "#{sign}$#{num.abs}"
  end
end

class Numeric
  def to_currency
    Currency.new(self)
  end
end

class Bankroll
  class << self
    fattr(:start) do
      Bankroll.new(:start_dt => Time.local(2008,10,14), :start_amount => 75000)
    end
  end
  attr_accessor :start_dt, :end_dt, :start_amount
  def initialize(ops)
    @start_dt = ops[:start_dt]
    @end_dt = ops[:end_dt] || Time.my_current.start_of_day
    @start_amount = ops[:start_amount]
  end
  fattr(:real_bets) do
    Game.has_wager.between(start_dt,end_dt).map { |x| x.bets }.flatten
  end
  fattr(:loose_bets) do
    LooseBet.between(start_dt,end_dt)
  end
  fattr(:bets) { real_bets + loose_bets }
  fattr(:change) do
    bets.map { |x| x.win_amount }.sum
  end
  fattr(:wagered_amount) do
    bets.map { |x| x.wagered_amount }.sum
  end
  def change_wagered_to_s
    "#{change.to_i.to_currency} on #{wagered_amount.to_i.to_currency}"
  end
  def current
    change + start_amount
  end
end

