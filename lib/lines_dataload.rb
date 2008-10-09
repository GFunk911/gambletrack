class LinesDataload
  def load_matchbook!
    Matchbook.new.line_hashes.each do |h|
      Line.find_or_create_from_hash(h)
    end
  end
end