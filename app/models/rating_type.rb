class RatingType < ActiveRecord::Base
  belongs_to :sport
  has_many :rating_periods
end
