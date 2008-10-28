class DataloadTasks
  include Singleton
  fattr(:all) { [] }
  def add(category,task_name,&b)
    all << DataloadTask.new(category,task_name,&b)
  end
  def get(category,task_name)
    all.find { |x| x.category == category.to_s and x.task_name == task_name.to_s }
  end
end

class DataloadTask
  attr_accessor :category, :task_name, :blk
  def initialize(category,task_name,&b)
    @category = category.to_s
    @task_name = task_name.to_s
    @blk = b
  end
  def run!
    blk.call
  end
end

def dataload_task(*args,&b)
  DataloadTasks.instance.add(*args,&b)
end

def load_ratings!(ops)
  sport = Sport.find_by_abbr(ops[:sport])
  
  rating_type = sport.rating_types.find_by_name(ops[:rating_type])
  unless rating_type
    rating_type = sport.rating_types.new(:name => ops[:rating_type]).tap { |x| x.save! }
  end
  period = sport.periods.all_containing(ops[:dt]).first
  rating_period = rating_type.rating_periods.new(:period_id => period.id).tap { |x| x.save! }
  sport.teams.each do |t|
    raw_rating = yield(t)
    points_rating = ops[:to_points_rating] ? ops[:to_points_rating].call(raw_rating) : raw_rating
    rating_period.ratings.new(:raw_rating => raw_rating, :points_rating => points_rating, :team_id => t.id).save!
  end
end

dataload_task(:load_ratings,'Load DVOA') do
  load_ratings!(:sport => 'NFL', :rating_type => 'DVOA', :dt => 1.days.ago, :to_points_rating => lambda { |x| x*20 }) do |t|
    get_dvoa_perc(t.abbr.to_sym)
  end
end

dataload_task(:load_ratings,'Load College Football Sagarin') do
  load_ratings!(:sport => 'CFB', :rating_type => 'Sagarin', :dt => Time.now) do |t|
    Sagarin.instance.get_rating(t.city)
  end
end

dataload_task(:load_ratings,'Load NBA Sagarin') do
  load_ratings!(:sport => 'NBA', :rating_type => 'Sagarin', :dt => Time.now) do |t|
    NBASagarin.instance.get_rating(t.city)
  end
end