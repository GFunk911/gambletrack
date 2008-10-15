class TeamName < ActiveRecord::Base
  belongs_to :team
  before_save do |t|
    t.full_name = "#{t.city} #{t.team_name}".strip
    t.search_string = t.gen_search_string
  end
  def gen_search_string
    "|" + [city,team_name,abbr,full_name].map { |x| (x||'').strip }.join("|").downcase + "|"
  end
  named_scope :matching, lambda { |t| {:conditions => ["search_string like ?","%|#{t.to_s.downcase}|%"]} }
  def self.load_csv!(ln)
    res = {}
    fields = ln.split(",").map { |x| x.strip }
    %w(city team_name abbr site_id primary).zip(fields[0..-3]).each { |f,v| res[f] = v unless v.blank? }
    sport_abbr = fields[-2]
    team_full_name = fields[-1]
    
    sport = Sport.find_by_abbr(sport_abbr)
    team = sport.teams.find(:first, :conditions => {:full_name => team_full_name})
    conds = res.reject { |k,v| k == 'primary' }
    tn = team.names.find(:first, :conditions => conds)
    if !tn
      team.names.new(res).save!
      puts "made team name #{res.inspect}"
    else
      puts "Already exists team name #{tn.full_name}"
    end
  end
  def csv
    raise "team is nil #{inspect}" unless team
    [city,team_name,abbr,nil,primary,team.sport.abbr,team.full_name].join(",")
  end
end
