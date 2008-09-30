class LineTeam < ActiveRecord::Migration
  def self.up
    add_column :lines, :team, :string
  end

  def self.down
  end
end
