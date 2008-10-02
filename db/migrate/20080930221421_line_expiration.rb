class LineExpiration < ActiveRecord::Migration
  def self.up
    add_column :lines, :effective_dt, :timestamp

    Line.find(:all).each { |x| x.save! }
  end

  def self.down
  end
end
