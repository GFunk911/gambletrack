class CreateTeamNames < ActiveRecord::Migration
  def self.up
    create_table :team_names do |t|
      t.integer :team_id, :null => false
      t.string :city
      t.string :team_name
      t.string :abbr
      t.string :full_name
      t.integer :site_id
      t.boolean :primary, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :team_names
  end
end
