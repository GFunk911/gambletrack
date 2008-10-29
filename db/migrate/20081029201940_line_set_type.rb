class LineSetType < ActiveRecord::Migration
  def self.up
    add_column :line_sets, :line_set_type, :string
    LineSet.all.each { |x| x.line_set_type ||= 'BookLineSet'; x.save! }
  end

  def self.down
  end
end
