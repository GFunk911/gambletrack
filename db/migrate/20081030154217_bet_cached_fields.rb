class BetCachedFields < ActiveRecord::Migration
  def self.up
    add_column :bets, :cached_win_amount, :float, :default => 0
    add_column :bets, :cached_if_win_amount, :float, :default => 0
  end

  def self.down
  end
end