class DropLineSetColumn < ActiveRecord::Migration
  def self.up
    remove_column :lines, :line_set_id
  end

  def self.down
  end
end
