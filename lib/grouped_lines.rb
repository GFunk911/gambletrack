class GroupedLines
  attr_accessor :lines, :group_blk, :headers, :fields
  def initialize(lines,headers,fields,&b)
    dbg "GroupedLines constructor"
    @lines = lines
    @headers = headers
    @group_blk = b 
    @fields = fields
  end
  fattr(:line_map) do
    lines.group_by { |x| group_blk[x] }.map_value { |x| EffectiveLine.new(x) }
  end
  def each(&b)
    dbg "GroupedLines size #{line_map.size}"
    if b.arity == 1
      line_map.values.sort.each(&b)
    else
      line_map.to_a.sort_by { |x| x[1] }.each { |a| yield(a[0],a[1]) }
    end
  end
  def pretty_fields
    fields.map do |x| 
      x.gsub(/_[a-z]/) { |m| " " + m[1..1].upcase }.gsub(/^[a-z]/) { |m| m.upcase }
    end
  end
end