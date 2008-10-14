class Site < ActiveRecord::Base
  has_many :lines
  def self.by_name(n)
    find_by_name(n)
  end
end
