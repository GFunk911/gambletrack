#module Enumerable
#  def each_catching_exceptions(&b)
    

class LinesDataload
  def load_matchbook_games_and_lines!
    Line
    load_matchbook_games!
    load_matchbook_lines!
    delete_cache!
  end
  def load_matchbook_games!
    Line
    Matchbook.new('CB').game_hashes.each do |h|
      GameCreator.new(h).run! #unless sport.to_s == 'PF'
    end
    delete_cache!
  end
  def load_matchbook_lines!
    Matchbook.new('CB').market_line_hashes.reject { |h| h[:event_name] =~ /mvp/i or h[:event_name] =~ /salami/i or h[:event_name] =~ /all.?star/i or h[:sport].nil? }.each do |h|
      Line.find_or_create_from_hash(h)
    end
  end
  def load_matchbook_bets!
    Matchbook.new('HK').real_offers.map { |x| x.line_hash }.each do |h|
      GameCreator.new(h).run!
      LineCreator.new(h).run!
      BetUpdater.new(h).run!
    end
  rescue => exp
    puts exp.message
  end
  def load_all_old!
    %w(PF CF HK BB BK CB).each do |s|
      load_matchbook_games_and_lines!(s)
    end
  end
  def load_all!
    load_teams!
    load_matchbook_games_and_lines!
  end
  def delete_cache!
    f = "#{RAILS_ROOT}/tmp/cache/views/75.101.152.201.1999/tree/show/1.cache"
    `rm #{f}` if FileTest.exists?(f)
  end
  def load_teams!
    Matchbook.new('CB').team_hashes.each do |h|
      TeamCreator.new(h).run!
    end
  end
  def load_predictions!
    PredictionLoad.line_hashes.each do |h|
      LineCreator.new(h).run!
    end
  end
end
