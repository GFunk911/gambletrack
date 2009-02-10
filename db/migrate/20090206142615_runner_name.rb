class RunnerName < ActiveRecord::Migration
  def self.up
    add_column :lines, :matchbook_runner_name, :string
  end

  def self.down
  end
end
