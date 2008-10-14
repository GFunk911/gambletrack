class Dataload
  def dump_teams!
    str = Team.all.map { |x| x.csv }.join("\n")
    File.create("#{RAILS_ROOT}/public/teams.csv",str)
    
    str = TeamName.all.map { |x| x.csv }.join("\n")
    File.create("#{RAILS_ROOT}/public/team_names.csv",str)
  end
  
  def load_teams!
    lines = File.open("#{RAILS_ROOT}/public/teams.csv") { |f| f.to_a }
    if lines.size == Team.all.size
      puts "Already #{lines.size} teams, not running team load"
    else
      lines.each { |ln| Team.load_csv!(ln) }
    end
    
    lines = File.open("#{RAILS_ROOT}/public/team_names.csv") { |f| f.to_a }
    if lines.size == TeamName.all.size
      puts "Already #{lines.size} team names, not running team name load"
    else
      lines.each { |ln| TeamName.load_csv!(ln) }
    end
  end
end

class Time
  def self.my_current
    now
  end
end

def eat_exceptions(msg_if_exp=nil)
  yield
rescue => exp
  puts msg_if_exp if msg_if_exp
  return nil
end

