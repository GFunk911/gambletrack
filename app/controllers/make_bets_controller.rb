class MakeBetsController < ApplicationController
  def create
    @bet = MakeBet.new(params[:make_bet])
    @bet.make_bet
  end
end
