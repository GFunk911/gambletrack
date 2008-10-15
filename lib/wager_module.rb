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
  def lines_grouped_by_line
    GroupedLines.new(lines_with_bet,%w(Line),%w(desired_amount wagered_amount win_amount)) { |x| x.desc }
  end
  def lines_grouped_by_effective_line
    GroupedLines.new(effective_lines.select { |x| x.has_bet? },%w(BetType Team),%w(desired_amount wagered_amount win_amount)) { |x| [x.bet_type,x.team] }
  end
  def effective_lines
    lines.group_by { |x| [x.bet_type,x.team] }.values.map { |x| EffectiveLine.new(x) }
  end
end