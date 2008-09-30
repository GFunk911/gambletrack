class GameResult < ActiveRecord::Migration
  def self.up
    add_column :games, :home_score, :integer
    add_column :games, :away_score, :integer
  end

  def self.down
  end
end
