class LoadMoreSites < ActiveRecord::Migration
  def self.up
    %w(Pinnacle CRIS Skybook BetUS WSEX PinnacleOpen SportsBet).each { |site| Site.new(:name => site).save! }
  end

  def self.down
  end
end
