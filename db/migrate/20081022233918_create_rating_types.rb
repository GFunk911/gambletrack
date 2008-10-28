class CreateRatingTypes < ActiveRecord::Migration
  def self.up
    create_table :rating_types do |t|
      t.integer :sport_id, :null => false
      t.string :name, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :rating_types
  end
end
