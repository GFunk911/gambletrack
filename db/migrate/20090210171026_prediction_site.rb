class PredictionSite < ActiveRecord::Migration
  def self.up
    Site
    Sportsbook.new(:name => 'Prediction').save!
  end

  def self.down
  end
end
