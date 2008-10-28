class CreateRatingPeriods < ActiveRecord::Migration
  def self.up
    create_table :rating_periods do |t|
      t.integer :rating_type_id, :null => false
      t.integer :period_id
      t.timestamps
    end
  end

  def self.down
    drop_table :rating_periods
  end
end
