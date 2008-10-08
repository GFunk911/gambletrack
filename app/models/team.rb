class Team < ActiveRecord::Base
  belongs_to :sport
  has_many :names, :class_name => 'TeamName'
  after_save do |t|
    t.names.new(:abbr => t.abbr, :team_name => t.team_name, :city => t.city, :primary => true).save! if t.names.empty?
  end
  before_save do |t|
    t.full_name = t.city + " " + t.team_name
  end
  validates_uniqueness_of :abbr
end
