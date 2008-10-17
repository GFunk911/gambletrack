class HockeyPeriods < ActiveRecord::Migration
  def self.up
    start = Time.local(2008,10,6)
    sport = Sport.find_by_abbr('NHL')
    
    if sport.periods.size == 1
      200.times do 
        e = start + 1.days
        n = start.strftime("%b %d")
        sport.periods.new(:name => n, :start_dt => start, :end_dt => e).save!
        start += 1.days
      end
      
      sport.periods.find_by_name('NHL Entire Season').destroy
    end
    
    sport.games.each { |g| g.period = sport.periods.all_containing(g.event_dt).first; g.save! }
  end

  def self.down
  end
end
