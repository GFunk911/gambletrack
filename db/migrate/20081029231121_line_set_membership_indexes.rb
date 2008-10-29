class LineSetMembershipIndexes < ActiveRecord::Migration
  def self.up
    add_index :line_set_memberships, :line_id
    add_index :line_set_memberships, :line_set_id
  end

  def self.down
  end
end
