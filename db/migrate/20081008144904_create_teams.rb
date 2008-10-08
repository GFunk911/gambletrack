class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.string :city
      t.string :team_name
      t.string :abbr
      t.string :full_name
      t.integer :sport_id
      t.timestamps
    end
  end

  def self.down
    drop_table :teams
  end
end
