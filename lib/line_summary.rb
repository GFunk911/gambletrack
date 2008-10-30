module LineSummary
  def num_wins
    line_summary_children.select { |x| x.win? }.size
  end
  def num_losses
    line_summary_children.select { |x| x.loss? }.size
  end
  def num_pushes
    line_summary_children.select { |x| x.push? }.size
  end
  def num_unplayed
    line_summary_children.select { |x| x.unplayed? }.size
  end
  def roi
    (win_amount.to_f / wagered_amount_on_played_games.to_f).to_perc
  end
end