class EffectiveLine
  include BetSummary
  include LineResult
  include Enumerable
  include LineSummary
  def initialize(a)
    @arr = a
  end
  def each(&b)
    @arr.each(&b)
  end
  def bet_children
    @arr
  end
  def result
    @arr.first.result
  end
  def method_missing(sym,*args,&b)
    @arr.first.send(sym,*args,&b)
  end
  def line_summary_children
    @arr.first.respond_to?(:line_summary_children) ? @arr.map { |x| x.line_summary_children }.flatten : @arr
  end
end