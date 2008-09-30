class Bet < ActiveRecord::Base
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
