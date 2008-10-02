class FillLineSet < ActiveRecord::Migration
  def self.up
    Line.all.each { |x| x.save! }
  end

  def self.down
  end
end
