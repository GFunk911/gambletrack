class CreateIndexes < ActiveRecord::Migration
  def self.up
    add_index :bets, :line_id
    add_index :lines, :game_id
    add_index :lines, :line_set_id
    add_index :sites, :id
    add_index :games, :period_id
    add_index :games, :id
    add_index :lines, :id
  end

  def self.down
  end
end
