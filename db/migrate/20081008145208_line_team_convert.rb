class LineTeamConvert < ActiveRecord::Migration
  def self.up
    add_column :lines, :team_id, :integer
    add_column :line_sets, :team_id, :integer
    
    teams = Team.all.group_by { |x| x.abbr }.map_value { |x| x.first.id }
    Line.all.each do |g|
      g.team_id = teams[g.team].tap { |x| raise "no team #{g.team}" unless x }
      g.save!
    end
    LineSet.all.each do |g|
      g.team_id = teams[g.team].tap { |x| raise "no team #{g.team}" unless x }
      g.save!
    end
    
    remove_column :lines, :team
    remove_column :line_sets, :team
  end

  def self.down
  end
end
