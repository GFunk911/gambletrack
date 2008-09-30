class CreateBets < ActiveRecord::Migration
  def self.up
    create_table :bets do |t|
      t.integer :line_id, :null => false
      t.float :desired_amount, :default => 0
      t.float :outstanding_amount, :default => 0
      t.float :wagered_amount, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :bets
  end
end
