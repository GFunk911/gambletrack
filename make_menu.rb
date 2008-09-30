#!/usr/bin/env ruby

def ec(x)
  puts x
  res = `#{x}`
  puts res unless res.strip == ''
  raise "failure" unless $?.success?
end

class RailsFile
  attr_accessor :path
  def initialize(path)
    @path = File.expand_path(path)
  end
  def view?
    path =~ /views/
  end
  def base
    File.basename(path)
  end
  def last_dir
    File.dirname(path).split("/")[-1]
  end
  def care?
    if helper?
      false
    elsif migration?
      true
    elsif view?
      care_about.any? { |care| path =~ /views\/#{care}/ }
    else
      care_about.any? { |care| base =~ /^#{care}/ }
    end
  end
  def helper?
    path =~ /helpers/
  end
  def migration?
    path =~ /migrate/
  end
  def link_name
    if view?
      "#{last_dir}-#{base}"
    else
      base
    end
  end
  def link_dir
    if view?
      "views"
    else
      last_dir.gsub(/migrate/,"migrations")
    end
  end
  def link!
    raw_link! if care?
  end
  def raw_link!
    ln path,"#{link_dir}/#{link_name}"
  end
end

CARE_ABOUT = %w(bet game line main tree)
def care_about
  CARE_ABOUT
end

def prepare!
  %w(controllers models views migrations).each { |x| ec "mkdir menu/#{x}" }
end

def clear!
  Dir["menu/*"].each { |x| ec "rm -r #{x}" }
end

def ln(path,name)
  ec "ln -s #{File.expand_path(path)} menu/#{name}"
end

clear!
prepare!
Dir["app/**/*.*"].map { |x| RailsFile.new(x) }.each { |x| x.link! }
%w(config/environment.rb config/routes.rb db/schema.rb).each { |x| ln x,File.basename(x) } 
Dir["db/migrate/*.*"].map { |x| RailsFile.new(x) }.each { |x| x.link! }
ln ".","root"

