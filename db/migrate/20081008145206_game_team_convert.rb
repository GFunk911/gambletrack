class GameTeamConvert < ActiveRecord::Migration
  def self.up
    Game.all.each do |g|
      teams = Team.all.group_by { |x| x.abbr }.map_value { |x| x.first.id }
      g.home_team_id = teams[g.home_team].tap { |x| raise "no team #{g.home_team}" unless x }
      g.away_team_id = teams[g.away_team].tap { |x| raise "no team #{g.away_team}" unless x }
      g.save!
    end
  end

  def self.down
  end
end
