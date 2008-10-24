class Time
  def start_of_day
    klass.local(year,month,day)
  end
end

class Time
  def same_day_as?(t)
    t.year == year and t.month == month and t.day == day
  end
  def today?
    same_day_as?(Time.now)
  end
  def yesterday?
    same_day_as?(Time.now - 1.days)
  end
end
    
class Time
  def self.my_current
    now
  end
end

class Time
  def pretty
    strftime("%m/%d")
  end
end

class Time
  def pretty_dt
    strftime("%m/%d %H:%M")
  end
end