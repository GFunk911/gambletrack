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
  belongs_to :team_obj, :class_name => 'Team', :foreign_key => 'team_id'
  def team
    team_obj.abbr
  end
  include BetSummary
  def rfd
    Gambling::Odds.get(odds).rfd
  end
  def possible_teams
    if game
      game.teams
    else
      Team.all
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
    ls = lines.reject { |x| x.expire_dt }.sort_by { |x| x.created_at }
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
