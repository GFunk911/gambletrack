class Spread
  attr_accessor :fb
  def initialize(fb)
    @fb = fb ? fb.to_closest_spread : fb
  end
  def to_s
    if fb > 0
      "-#{fb}"
    else
      "+#{fb*-1}"
    end
  end
end
  
