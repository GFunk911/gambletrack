class PopulateCachedConsensusFields < ActiveRecord::Migration
  def self.up
    LineConsensus.find(:all, :conditions => 'bets > 0', :order => 'created_at asc').each { |x| x.save! }
  end

  def self.down
  end
end
