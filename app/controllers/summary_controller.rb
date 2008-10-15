class SummaryController < ApplicationController
  def show
    Sport
    render :partial => 'game/line_summary', :object => Sports.new
  end
end
