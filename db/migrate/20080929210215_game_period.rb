class GamePeriod < ActiveRecord::Migration
  def self.up
    add_column :games, :period_id, :integer
    ps = Period.find(:all)
    Game.find(:all).each do |g|
      g.period = ps.find { |x| x.start_dt < g.event_dt and x.end_dt > g.event_dt }
      g.save!
    end
  end

  def self.down
  end
end
