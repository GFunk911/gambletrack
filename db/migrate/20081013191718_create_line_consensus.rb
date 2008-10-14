class CreateLineConsensus < ActiveRecord::Migration
  def self.up
    create_table :line_consensus do |t|
      t.integer :line_id
      t.integer :game_id
      t.integer :bets
      t.decimal :bet_percent
      t.timestamps
    end
  end

  def self.down
    drop_table :line_consensus
  end
end
