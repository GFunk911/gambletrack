class CreateLines < ActiveRecord::Migration
  def self.up
    create_table :lines do |t|
      t.integer :game_id, :null => false
      t.float :spread
      t.float :return_from_dollar
      t.string :status
      t.integer :site_id
      t.timestamp :expire_dt
      t.timestamps
    end
  end

  def self.down
    drop_table :lines
  end
end
