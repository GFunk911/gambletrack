class CreatePeriods < ActiveRecord::Migration
  def self.up
    create_table :periods do |t|
      t.string :name, :null => false
      t.timestamp :start_dt
      t.timestamp :end_dt
      t.timestamps
    end
    (1..17).each do |w|
       s,e = *Game.dates_for_week(w)
       Period.new(:start_dt => s, :end_dt => e, :name => "Week #{w}").save!
    end
  end

  def self.down
    drop_table :periods
  end
end
