class TeamName < ActiveRecord::Base
  belongs_to :team
  before_save do |t|
    t.full_name = (t.city + " " + (t.team_name||'')).strip
    t.search_string = t.gen_search_string
  end
  def gen_search_string
    [city,team_name,abbr,full_name].map { |x| (x||'').strip }.join("|").downcase
  end
  named_scope :matching, lambda { |t| {:conditions => ["search_string like ?","%|#{t.to_s.downcase}|%"]} }
end
