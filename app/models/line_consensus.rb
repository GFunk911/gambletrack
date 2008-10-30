class LineConsensus < ActiveRecord::Base
  belongs_to :line
  def setup_line_set_cache!
    line.line_sets.each do |set|
      set.cached_bets = bets
      set.cached_bet_percent = bet_percent
      set.save!
    end
  end
  after_save { |x| x.setup_line_set_cache! }
end
