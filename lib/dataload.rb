class Dataload
  def dump_teams!
    str = Team.all.map { |x| x.csv }.join("\n")
    File.create("#{RAILS_ROOT}/public/teams.csv",str)
    
    str = TeamName.all.map { |x| x.csv }.join("\n")
    File.create("#{RAILS_ROOT}/public/team_names.csv",str)
  end
  
  def team_csv_files
    res = []
    res << "#{RAILS_ROOT}/public/teams.csv"
    res << "#{RAILS_ROOT}/public/cbb_teams.csv"
    res += Dir["#{RAILS_ROOT}/public/team_load/teams/*.csv"]
    res.select { |x| FileTest.exists?(x) }
  end
  
  def team_name_csv_files
    res = []
    res << "#{RAILS_ROOT}/public/team_names.csv"
    res += Dir["#{RAILS_ROOT}/public/team_load/team_names/*.csv"]
    res.select { |x| FileTest.exists?(x) }
  end
  
  def load_teams!
    team_csv_files.each do |filename|
      lines = File.open(filename) { |f| f.to_a }
      lines.each { |ln| Team.load_csv!(ln) }
    end
    
    team_name_csv_files.each do |filename|
      lines = File.open(filename) { |f| f.to_a }
      if lines.size == TeamName.all.size
        puts "Already #{lines.size} team names, not running team name load"
      else
        lines.each { |ln| TeamName.load_csv!(ln) }
      end
    end
  end
end
