class SummaryController < ApplicationController
  #caches_page :show
  def show
    obj = (params[:id] == 'Sports') ? Sports.new : Sport.find(params[:id])
    render :partial => 'game/line_summary', :object => obj
  end
end
