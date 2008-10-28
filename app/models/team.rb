class Team < ActiveRecord::Base
  belongs_to :sport
  has_many :names, :class_name => 'TeamName'
  after_save do |t|
    t.names.new(:abbr => t.abbr, :team_name => t.team_name, :city => t.city, :primary => true).save! if t.names.empty?
  end
  before_save do |t|
    t.full_name = "#{t.city} #{t.team_name}".strip
  end
  validates_uniqueness_of :abbr, :allow_nil => true, :scope => :sport_id
  def to_s
    abbr.blank? ? city : abbr
  end
  def self.load_csv!(ln)
    res = {}
    fields = ln.split(",").map { |x| x.strip }
    %w(city team_name abbr).zip(fields[0..-2]).each { |f,v| res[f] = v unless v.blank? }
    sport_abbr = fields[-1]
    
    t = nil
    sport = nil
    if sport_abbr.blank?
      t = Team.find(:first, :conditions => res)
    else
      sport = Sport.find_by_abbr(sport_abbr)
      t = sport.teams.find(:first, :conditions => res)
    end
    if !t
      if sport
        sport.teams.new(res).save!
      else
        Team.new(res).save!
      end
      puts "made team #{res.inspect}"
    else
      puts "Already exists team #{t.full_name}"
    end
  end
  def csv
    [city,team_name,abbr,sport.abbr].join(",")
  end
  def short_name
    abbr ? abbr : city
  end
  class << self
    fattr(:ou_teams) do
      find(:all, :conditions => ["city = ? or city = ?",'Over','Under'])
    end
  end
  def self.over_under?(t)
    %w(over under).include?(t.to_s.downcase)
  end
  def over_under?
    klass.over_under?(city)
  end
end
