class LineSetCachedFields < ActiveRecord::Migration
  def self.up
    add_column :line_sets, :cached_bets, :integer
    add_column :line_sets, :cached_bet_percent, :float
    add_column :line_sets, :cached_desired_amount, :float, :default => 0
    add_column :line_sets, :cached_wagered_amount, :float, :default => 0
    add_column :line_sets, :cached_win_amount, :float, :default => 0
  end

  def self.down
  end
end
