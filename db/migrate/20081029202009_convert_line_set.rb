class ConvertLineSet < ActiveRecord::Migration
  def self.up
    LineSetMembership.all.each { |x| x.destroy }
    Line.all.each do |ln|
      LineSetMembership.new(:line_set_id => ln.line_set_id, :line_id => ln.id).save!
    end
  end

  def self.down
  end
end
