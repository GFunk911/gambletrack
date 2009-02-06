module DailySummaryHelper
  def market_status_hash(game)
    {:update => "market_status_#{game.id}", :url => {:action => 'market_status', :id => game.id, :team => game.anti_public_team.id}}
  end
  def offers
    Matchbook.new('CB').real_offers
  rescue => exp
    return exp.message
  end
end
