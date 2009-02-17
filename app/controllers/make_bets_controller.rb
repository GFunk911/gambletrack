class MakeBetsController < ApplicationController
  def create
    @bet = MakeBet.new(params[:make_bet])
    @bet.make_bet
    LinesDataload.new.load_matchbook_bets!
  end
end
