class TeamName < ActiveRecord::Base
  belongs_to :team
  before_save do |t|
    t.full_name = t.city + " " + t.team_name
  end
end
