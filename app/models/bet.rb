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
end
