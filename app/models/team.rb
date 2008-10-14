class Team < ActiveRecord::Base
  belongs_to :sport
  has_many :names, :class_name => 'TeamName'
  after_save do |t|
    t.names.new(:abbr => t.abbr, :team_name => t.team_name, :city => t.city, :primary => true).save! if t.names.empty?
  end
  before_save do |t|
    t.full_name = (t.city + " " + (t.team_name||'')).strip
  end
  validates_uniqueness_of :abbr, :allow_nil => true
  def to_s
    abbr.blank? ? city : abbr
  end
  def self.load_csv!(ln)
    res = {}
    fields = ln.split(",").map { |x| x.strip }
    %w(city team_name abbr).zip(fields[0..-2]).each { |f,v| res[f] = v unless v.blank? }
    sport_abbr = fields[-1]
    
    sport = Sport.find_by_abbr(sport_abbr)
    t = sport.teams.find(:first, :conditions => res)
    if !t
      sport.teams.new(res).save!
      puts "made team #{res.inspect}"
    else
      puts "Already exists team #{t.full_name}"
    end
  end
  def csv
    [city,team_name,abbr,sport.abbr].join(",")
  end
end
