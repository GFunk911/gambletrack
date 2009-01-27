class LineMatchbookIds < ActiveRecord::Migration
  def self.up
    add_column :lines, :matchbook_market_id, :string
    add_column :lines, :matchbook_runner_id, :string
  end

  def self.down
  end
end
