class SportHomeAdv < ActiveRecord::Migration
  def self.up
    add_column :sports, :home_advantage, :float
    {:NFL => 3, :CFB => 3, :NHL => 0, :NBA => 4, :MLB => 0}.each do |s,num|
      sport = Sport.find_by_abbr(s.to_s)
      sport.home_advantage = num
      sport.save!
    end
  end

  def self.down
  end
end
