class LoadSites < ActiveRecord::Migration
  def self.up
    ['VIP','Matchbook','GhettoBet','Tradesports'].each do |site|
      Site.new(:name => site).save!
    end
  end

  def self.down
  end
end
