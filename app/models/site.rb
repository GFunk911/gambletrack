class Site < ActiveRecord::Base
  has_many :lines
  before_save { |x| x.write_attribute(:type,'Sportsbook') unless x.read_attribute(:type) }
  def self.by_name(n)
    find_by_name(n)
  end
end

class Sportsbook < Site
  def changes_spread?
    true
  end
end

class Exchange < Site
  def changes_spread?
    false
  end
end
