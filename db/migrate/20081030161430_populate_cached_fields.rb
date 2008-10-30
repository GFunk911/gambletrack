class PopulateCachedFields < ActiveRecord::Migration
  def self.up
    a = LineSet.all
    a.each_with_index do |set,i|
      puts "LineSet #{i} of #{a.size}" if i%250 == 0
      set.setup_cache!
    end
    
    a = Bet.all
    a.each_with_index do |bet,i|
      puts "Bet #{i} of #{a.size}" if i%250 == 0
      bet.setup_cache!
    end
  end

  def self.down
  end
end
