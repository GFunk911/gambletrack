module DailySummaryHelper
  def market_status_hash(game)
    {:update => "market_status_#{game.id}", :url => {:action => 'market_status', :id => game.id, :team => game.anti_public_team.id}}
  end
end
