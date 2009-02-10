require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'fattr'

module FromHash
  def from_hash(ops)
    ops.each do |k,v|
      send("#{k}=",v)
    end
  end
  def initialize(ops={})
    from_hash(ops)
  end
end

class PredictionRow
  include FromHash
  attr_accessor :line, :sport
  fattr(:home) { line[0...21].strip }
  fattr(:away) { line[21...39].strip }
  fattr(:prediction) { line[62..68].to_f }
  def line_hash
    res = {:home_team => home, :away_team => away, :event_dt => Time.now, :sport => sport, :site => 'Prediction'}
    res.merge(:team => home, :spread => prediction, :odds => '-110')
  end
  def self.all
    doc = Hpricot(open("http://www.thepredictiontracker.com/predbb.html"))
    doc.search("//pre").first.innerText.split("\n")[6..-1].map do |x|
      PredictionRow.new(:line => x)
    end
  end
  def self.line_hashes
    all.map { |x| x.line_hash }
  end
end

class PredictionLoad
  include FromHash
  attr_accessor :sport
  def url
    sp = {'CBB' => 'bb', 'NBA' => 'nba'}[sport]
    "http://www.thepredictiontracker.com/pred#{sp}.html"
  end
  fattr(:starting_line_num) do
    ind = nil
    text.split("\n").each_with_index do |x,i|
      ind = i if x.strip =~ /^Games of/
    end
    ind + 5
  end
  fattr(:text) do
    doc = Hpricot(open(url))
    doc.search("//pre").first.innerText
  end
  fattr(:rows) do
    text.split("\n").each_with_index do |x,i|
      puts "#{i}: #{x}"
    end
    text.split("\n")[starting_line_num..-1].map do |x|
      PredictionRow.new(:line => x, :sport => sport)
    end
  end
  def line_hashes
    rows.map { |x| x.line_hash }
  end
  def self.line_hashes
    ['CBB','NBA'].map do |sport|
      PredictionLoad.new(:sport => sport).line_hashes
    end.flatten
  end
end
    
