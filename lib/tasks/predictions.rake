namespace :predictions do
  task :load do
    require(File.join(File.dirname(__FILE__), '..','..','config', 'environment'))
    LinesDataload.new.load_predictions!
  end
end