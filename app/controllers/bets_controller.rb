class BetsController < ApplicationController
  def line
    @line ||= Line.find(params[:line_id])
  end
  def new
    @bet = line.bets.new
  end
  def create
    @bet = line.bets.new(params[:bet])
    @bet.save!
    redirect_to :action => 'new'
  end
  def edit
    @bet = line.bets.first
    render :template => 'bets/new'
  end
  def update
    @bet = line.bets.first
    raise 'failure' unless @bet.update_attributes(params[:bet])
    redirect_to :action => 'new'
  end
end
