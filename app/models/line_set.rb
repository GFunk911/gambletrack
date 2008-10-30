class LineSets
  def children
    LineSet.find(:all)
  end
  def desc
    "linesets"
  end
end

class LineSet < ActiveRecord::Base
  has_many :line_set_memberships
  has_many :lines, :through => :line_set_memberships
  has_many :bets, :through => :lines
  belongs_to :game
  belongs_to :team_obj, :class_name => 'Team', :foreign_key => 'team_id'
  set_inheritance_column :line_set_type
  before_save do |x|
    x.bet_type ||= x.calc_bet_type if x.calc_bet_type
  end
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
  def calc_bet_type
    return nil unless spread
    (spread.to_f == 0) ? 'moneyline' : 'spread'
  end
  def self.get_base_key(l)
    {:game_id => l.game_id, :team_id => l.team_id, :bet_type => l.bet_type||l.calc_bet_type }
  end
end

# game,team,bet_type are implied
class BookLineSet < LineSet
  def self.get_key(l)
    res = get_base_key(l).merge(:site_id => l.site_id)
    res[:spread] = l.spread.to_closest_spread unless l.site.changes_spread? 
    res
  end
end

class SpreadLineSet < LineSet
  def self.get_key(l)
    get_base_key(l).merge(:spread => l.spread.to_closest_spread)
  end
end

class BetTypeLineSet < LineSet
  def self.get_key(l)
    get_base_key(l)
  end
  def spread_str
    lines.map { |x| x.spread }.uniq.join("/")
  end
end
