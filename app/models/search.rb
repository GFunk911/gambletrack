class Search < ActiveRecord::Base
  serialize :search_params
  attr_accessor :save
  def search_object
    Game.new_search(search_params)
  end
end
