module WagerModule
  def wagers
    lines.map { |x| x.wagers }.flatten.sort_by { |x| x.kelly_perc }.reverse
  end
  def active_wagers
    lines.select { |x| x.active? }.map { |x| x.wagers }.flatten.sort_by { |x| x.kelly_perc }.reverse
  end
  def lines_with_bet
    lines.select { |x| x.has_bet? }
  end
end