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
  def win_amount
    line.result_factor * wagered_amount
  rescue => exp
    puts exp
    return :null_win_amount
  end
  %w(desired_amount outstanding_amount wagered_amount).each do |m|
    define_method("#{m}=") do |amt|
      amt = (amt.strip[0..-2].to_f * BetSummary.unit_size) if amt.to_s.strip[-1..-1] == 'u'
      write_attribute(m,amt)
    end
  end
end
