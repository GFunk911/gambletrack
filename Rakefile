# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

namespace :dataload do
  task :mb_lines do
    require(File.join(File.dirname(__FILE__), 'config', 'environment'))
    Matchbook.instance.line_hashes.each do |h|
      Line.find_or_create_from_hash(h)
    end
  end
  task :lineset do
    require(File.join(File.dirname(__FILE__), 'config', 'environment'))
    Line.find(:all).each { |x| x.save! }
  end
end

task :delete_bad_lines do
  require(File.join(File.dirname(__FILE__), 'config', 'environment'))
  Line.find(:all, :conditions => ["return_from_dollar <= 0 or return_from_dollar >= 100"]).each { |x| x.destroy }
end