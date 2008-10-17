#module Enumerable
#  def each_catching_exceptions(&b)
    

class LinesDataload
  def load_matchbook_sport!(sport)
    Matchbook.new(sport).line_hashes.each do |h|
      Line.find_or_create_from_hash(h)
    end
  end
  def load_matchbook!
    %w(PF).each { |x| load_matchbook_sport!(x) }
  end
  def load_matchbook_games!(sport)
    Line
    Matchbook.new(sport).line_hashes.each do |h|
      GameCreator.new(h).run!
    end
  end
  def load_matchbook_both!(s)
    load_matchbook_games!(s)
    load_matchbook_sport!(s)
  end
  def load_all!
    load_matchbook!
    %w(CF HK BB).each do |s|
      load_matchbook_both!(s)
    end
  end
end