class RatingPeriod < ActiveRecord::Base
  belongs_to :rating_type
  belongs_to :period
  has_many :ratings
end
