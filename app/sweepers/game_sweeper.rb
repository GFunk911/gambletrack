class GameSweeper < ActionController::Caching::Sweeper
  observe Game, Line, Bet # This sweeper is going to keep an eye on the Post model

  # If our sweeper detects that a Post was created call this
  def get_game(g)
    return g if g.is_a?(Game)
    return g.game if g.respond_to?(:game)
    return g.line.game if g.is_a?(Bet)
    nil
  end
  def after_create(obj)
    #5.times { puts "SWEEPER AFTER CREATE" }
    game = get_game(obj)
    return unless game
    expire_page(:controller => 'main', :action => 'index')
  end
  def after_save(obj)
    #d = obj.respond_to?(:desc) ? obj.desc : ""
    #puts "SWEEPER AFTER SAVE #{obj.class} #{d} #{obj.id}"
    game = get_game(obj)
    return unless game
    #puts "SWEEPER AFTER SAVE RUNNING"
    expire_page(:controller => 'game', :action => 'show', :id => game.id)
    expire_page(:controller => 'period', :action => 'show', :id => game.period.id) if game.period
    expire_page(:controller => 'summary', :action => 'show', :id => game.sport.id) if game.sport
    expire_page(:controller => 'summary', :action => 'show', :id => 'Sports')
    #puts "SWEEPER AFTER SAVE END"
  end
end