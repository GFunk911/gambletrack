class CreateLineSets < ActiveRecord::Migration
  def self.up
    create_table :line_sets do |t|
      t.integer :game_id, :null => false
      t.float :spread
      t.float :return_from_dollar
      t.string :status
      t.integer :site_id
      t.timestamp :expire_dt
      t.string :team
      t.timestamps
    end
    add_column :lines, :line_set_id, :integer
  end


  def self.down
    drop_table :line_sets
  end
end
