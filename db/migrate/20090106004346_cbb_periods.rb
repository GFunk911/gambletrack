class CbbPeriods < ActiveRecord::Migration
  def self.up
    start = Time.local(2008,11,1)
    sport = Sport.find_by_abbr('CBB')
    
    180.times do 
      e = start + 1.days
      n = start.strftime("%b %d")
      sport.periods.new(:name => n, :start_dt => start, :end_dt => e).save!
      start += 1.days
    end
  end

  def self.down
  end
end
