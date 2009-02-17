class Bet < ActiveRecord::Base
  Line
  include LineResult
  def result
    line.result
  end
  belongs_to :line
  def blank?
    (desired_amount + outstanding_amount + wagered_amount) < 1
  end
  def calc_win_amount
    line.result_factor * wagered_amount
  rescue => exp
    0
  end
  def calc_if_win_amount
    line.win_result_factor * wagered_amount
  rescue => exp
    0
  end
  def win_amount
    cached_win_amount
  end
  def if_win_amount
    cached_if_win_amount
  end
  def unmatched_amount
    outstanding_amount - wagered_amount
  end
  %w(desired_amount outstanding_amount wagered_amount).each do |m|
    define_method("#{m}=") do |amt|
      amt = (amt.strip[0..-2].to_f * BetSummary.unit_size) if amt.to_s.strip[-1..-1] == 'u'
      amt = amt.to_f.round_dec(4)
      write_attribute(m,amt)
    end
  end
  named_scope(:has_wager,lambda do
    {:conditions => ["wagered_amount > 0"]  }
  end)
  after_save { |x| CacheManager.new.expire_bet!(x) }
  after_save { |x| x.set_line_set_cache! }
  def set_line_set_cache!
    return unless wagered_amount_changed? or desired_amount_changed?
    line.line_sets.each do |set|
      set.cached_wagered_amount += wagered_amount - wagered_amount_was
      set.save!
    end
  end
  def setup_cache!
    self.cached_win_amount = calc_win_amount
    self.cached_if_win_amount = calc_if_win_amount
  end
  before_save { |x| x.setup_cache! if x.wagered_amount_changed? }
  def short_to_s
    res = []
    res << line.odds
    res << "M: $#{wagered_amount}" if wagered_amount > 0.1
    res << "U: $#{unmatched_amount}" if unmatched_amount > 0.1
    res.join(" ")
  end
end
