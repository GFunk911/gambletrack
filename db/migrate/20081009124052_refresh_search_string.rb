class RefreshSearchString < ActiveRecord::Migration
  def self.up
    TeamName.all.each { |x| x.save! }
  end

  def self.down
  end
end