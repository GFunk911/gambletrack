class TeamNameSearchString < ActiveRecord::Migration
  def self.up
    add_column :team_names, :search_string, :string
  end

  def self.down
  end
end