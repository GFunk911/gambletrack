class LineSetMembership < ActiveRecord::Base
  belongs_to :line_set
  belongs_to :line
  belongs_to :book_line_set, :foreign_key => 'line_set_id'
  belongs_to :spread_line_set, :foreign_key => 'line_set_id'
  belongs_to :bet_type_line_set, :foreign_key => 'line_set_id'
  validates_uniqueness_of :line_id, :scope => :line_set_id
end
