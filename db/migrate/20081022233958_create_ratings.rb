class CreateRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.integer :rating_period_id, :null => false
      t.float :raw_rating
      t.float :points_rating
      t.integer :team_id
      t.timestamps
    end
  end

  def self.down
    drop_table :ratings
  end
end
