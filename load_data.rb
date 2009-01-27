require 'open-uri'

def load_page(url)
  puts "loading #{url} #{Time.now}"
  open(url)
  puts "loaded #{url} #{Time.now}"
rescue => exp
  puts Time.now.to_s + " " + exp.message.to_s
end

Dir.chdir("/root/gambletrack")
loop do
  #puts `rake load_data`
  puts "Starting load_data at #{Time.now}"
  begin
    load_page("http://75.101.152.201:1999/main/load_matchbook")
    load_page("http://75.101.152.201:1999/main/load_bets")
    load_page("http://75.101.152.201:1999/main/load_consensus")
    puts `rake copy_scores_local`
#    load_page("http://75.101.152.201:1999/main/load_scores")
    puts `rake scores`
#    load_page("http://75.101.152.201:1999/main/load_consensus")
    puts `rake fix_games`
  rescue
    puts "load_data threw exception at #{Time.now}"
  end  
  puts "Ending load_data at #{Time.now}"
  puts "sleeping for 20"
  sleep(60*20)
end
