class Search < ActiveRecord::Base
  serialize :search_params
  attr_accessor :do_save, :grouping_columns, :result_columns
  def initialize(*args)
    10.times { puts args.inspect }
    super(*args)
  end
  fattr(:search_object) do
    Game.new_search(search_params)
  end
  def grouping_columns
    @grouping_columns ||= []
  end
  def potential_grouping_columns
    %w(sport event_date)
  end
  def grouped_lines
    GroupedLines.new(search_object.all,grouping_columns,result_columns) { |x| grouping_columns.map { |col| x.send(col) } }
  end
  def result_columns
    @result_columns ||= []
  end
  def result_columns=(x)
    10.times { puts "RS #{x.inspect}"}
    @result_columns = x
  end
  def potential_result_columns
    %w(num_wins num_losses num_pushes wagered_amount win_amount roi)
  end
end
