class LineSets
  def children
    LineSet.find(:all)
  end
  def desc
    "linesets"
  end
end

class LineSet < ActiveRecord::Base
  has_many :lines
  belongs_to :game
  include BetSummary
  def rfd
    Gambling::Odds.get(odds).rfd
  end
  def find_matching
    lines.find { |x| x.spread == spread and x.return_from_dollar == rfd }
  end
  def save
    puts "LineSet#save"
    super.tap { |x| return x unless x }
    if !find_matching
      lines.new(:return_from_dollar => rfd, :game_id => game_id, :site_id => site_id, :spread => spread).save
    else
      true
    end
  end
  def possible_teams
    if game
      game.teams
    else
      games.map { |x| [x.home_team,x.away_team] }.flatten.map { |x| x.to_s }.uniq.sort
    end
  end
  def pretty_spread
    return spread unless spread
    spread * -1
  end
  def pretty_spread=(x)
    self.spread = (x ? x.to_f * -1 : x)
  end
  def bet_children
    lines
  end
  def result
    lines.first ? lines.first.result : nil
  end
  def mark_active!
    ls = lines.sort_by { |x| x.created_at }
    ls[0..-2].each { |x| x.expire_dt ||= Time.now; x.save! }
    #ls[-1].tap { |x| x.expire_dt = nil; x.save! }
  end
  def children
    lines
  end
  def desc
    "#{team} #{spread} #{odds}"
  rescue => exp
    puts exp
    return "line desc"
  end
end
