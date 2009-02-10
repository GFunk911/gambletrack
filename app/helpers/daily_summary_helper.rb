module DailySummaryHelper
  def market_status_hash(game)
    {:update => "market_status_#{game.id}", :url => {:action => 'market_status', :id => game.id, :team => game.anti_public_team.id}}
  end
  def offers
    Matchbook.new('CB').real_offers
  rescue => exp
    return exp.message
  end
  def margin_color(margin)
    return nil unless margin
    return 'green' if margin >= 2
    return 'red' if margin <= -2
    return 'yellow'
  end
  def total_score_color(game)
    return 'green' if game.bracket == 1
    return 'yellow' if game.bracket == 2
    return 'red' if game.bracket == 3
    nil
  end
end
