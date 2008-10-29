class CreateLineSetMemberships < ActiveRecord::Migration
  def self.up
    create_table :line_set_memberships do |t|
      t.integer :line_set_id, :null => false
      t.integer :line_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :line_set_memberships
  end
end
