class CacheManager < ActionController::Base
  include ActionController::Caching::Fragments
  def cache_configured?
    true
  end
  fattr(:cache_store) { ActionController::Base.cache_store }
  def expire_game_page!(game)
    expire_fragment(/game\/#{game.id}\.cache/)
  end
  def expire_period_page!(period)
    expire_fragment(/periods\/#{period.id}\.cache/)
  end
  def expire_top_left!
    expire_fragment(/main\/top_left\.cache/)
  end
  def expire_game!(game)
    expire_game_page!(game)
    if game.event_dt.today? or game.event_dt.yesterday?
      expire_top_left! if game.home_score_changed? or game.away_score_changed?
    end
    expire_period_page!(game.period) if game.home_score_changed? or game.away_score_changed?
  end
  def expire_bet!(bet)
    game = bet.line.game
    expire_game_page!(game)
    if game.event_dt.today? or game.event_dt.yesterday?
      expire_top_left! if bet.wagered_amount_changed?
    end
    expire_period_page!(game.period) if bet.wagered_amount_changed? or bet.outstanding_amount_changed? or bet.desired_amount_changed?
  end
  def expire_line!(line)
    game = line.game
    expire_game_page!(game)
    #if game.event_dt.today? or game.event_dt.yesterday?
    #  expire_top_left! if line.return_from_dollar_changed? or line.spread_changed?
    #end
  end
  def expire_game_tree!
    expire_fragment(/main\/game_tree\.cache/)
  end
end