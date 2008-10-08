class GameTeamDrop < ActiveRecord::Migration
  def self.up
    remove_column :games, :home_team
    remove_column :games, :away_team
  end

  def self.down
  end
end
