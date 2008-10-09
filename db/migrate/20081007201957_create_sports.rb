class CreateSports < ActiveRecord::Migration
  def self.up
    create_table :sports do |t|
      t.string :abbr
      t.string :name
      t.timestamps
    end
    add_column :games, :sport_id, :integer
    add_column :periods, :sport_id, :integer
    {'NFL' => 'Pro Football', 'CFB' => 'College Football'}.each do |a,n|
      Sport.new(:name => n, :abbr => a).save!
    end
    sid = Sport.find_by_abbr('NFL')
    Game.find(:all).each { |x| x.sport_id = sid; x.save! }
  end

  def self.down
    drop_table :sports
  end
end
