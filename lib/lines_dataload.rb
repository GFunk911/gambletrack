#module Enumerable
#  def each_catching_exceptions(&b)
    

class LinesDataload
  def load_matchbook_games_and_lines!(sport)
    Line
    Matchbook.new(sport).each_line_hash do |h|
      GameCreator.new(h).run! unless sport.to_s == 'PF'
      Line.find_or_create_from_hash(h)
    end
    delete_cache!
  end
  def load_matchbook_bets!
    Matchbook.new('HK').combined_offers.map { |x| x.line_hash }.each do |h|
      GameCreator.new(h).run!
      LineCreator.new(h).run!
      BetUpdater.new(h).run!
    end
  rescue => exp
    puts exp.message
  end
  def load_all!
    %w(PF CF HK BB BK).each do |s|
      load_matchbook_games_and_lines!(s)
    end
  end
  def delete_cache!
    f = "#{RAILS_ROOT}/tmp/cache/views/75.101.152.201.1999/tree/show/1.cache"
    `rm #{f}` if FileTest.exists?(f)
  end
end
