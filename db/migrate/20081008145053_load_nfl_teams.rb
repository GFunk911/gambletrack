class LoadNflTeams < ActiveRecord::Migration
  def self.up
    File.new("#{RAILS_ROOT}/lib/nfl_teams.csv").to_a.each do |ln|
      nfl = Sport.find_by_abbr("NFL")
      city,tname,abbr = *(ln.split(",").map { |x| x.strip })
      Team.new(:city => city, :team_name => tname, :abbr => abbr, :sport_id => nfl.id).save!
    end
  end

  def self.down
  end
end
