class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.string :home_team, :null => false
      t.string :away_team, :null => false
      t.timestamp :event_dt
      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
