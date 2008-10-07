# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

def rails_task(*args,&b)
  require(File.join(File.dirname(__FILE__), 'config', 'environment'))
  task(*args,&b)
end

namespace :dataload do
  rails_task :mb_lines do
    Matchbook.instance.line_hashes.each do |h|
      Line.find_or_create_from_hash(h)
    end
  end
  rails_task :scores do
    Game.update_nfl_games
  end
  rails_task :lineset do
    Line.find(:all).each { |x| x.save! }
  end
  rails_task :update_period_dates do
    t = Time.local(2008,9,9,2)
    (1..17).each do |w|
      p = Period.find_by_name("Week #{w}")
      p.end_dt = t
      p.save!
      t += 7.days
    end
  end
end

rails_task :delete_bad_lines do
  Line.find(:all, :conditions => ["return_from_dollar <= 0 or return_from_dollar >= 100"]).each { |x| x.destroy }
end
