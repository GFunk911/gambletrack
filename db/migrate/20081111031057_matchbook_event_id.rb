class MatchbookEventId < ActiveRecord::Migration
  def self.up
    add_column :games, :matchbook_event_id, :string
  end

  def self.down
  end
end
