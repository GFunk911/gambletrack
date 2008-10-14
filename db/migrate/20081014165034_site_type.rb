class SiteType < ActiveRecord::Migration
  def self.up
    add_column :sites, :type, :string
    Site.all.each { |x| x.save! }
    mb = Site.find_by_name('Matchbook')
    mb.write_attribute(:type,'Exchange')
    mb.save!
  end

  def self.down
  end
end
