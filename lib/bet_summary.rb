module BetSummary
  def bet_summary_end?
    !respond_to?(:children)
  end
  def desired_amount
    bet_children.map { |x| x.desired_amount||0 }.sum
  end
  def outstanding_amount
    bet_children.map { |x| x.outstanding_amount||0 }.sum
  end
  def wagered_amount
    bet_children.map { |x| x.wagered_amount||0 }.sum
  end
  def win_amount
    bet_children.map { |x| x.win_amount||0 }.sum
  end
  def has_bet?
    [desired_amount,wagered_amount].any? { |x| (x||0) > 0 }
  end
  def bet_children
    return bets if respond_to?(:bets)
    return games if respond_to?(:games)
    raise 'foo'
  end
end