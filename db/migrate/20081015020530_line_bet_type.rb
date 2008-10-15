class LineBetType < ActiveRecord::Migration
  def self.up
    add_column :lines, :bet_type, :string
    Line.all.each { |x| x.save! }
  end

  def self.down
  end
end
