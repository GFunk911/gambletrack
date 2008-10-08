class GameTeam < ActiveRecord::Migration
  def self.up
    add_column :games, :home_team_id, :integer
    add_column :games, :away_team_id, :integer
  end

  def self.down
  end
end
