def load_line!(ln)
  res = {}
  res[:home_team] = ln['Home Team']
  res[:away_team] = ln['Away Team']
  res[:event_dt] = Time.parsedate(ln['Date'])
  res[:team] = ln['Bet On']
  res[:site] = 'Matchbook'
  res[:bet_type] = ln['Type']
  res[:spread] = ln['Line'].to_f
  res[:odds] = ln['Juice']
  res[:sport] = ln['Sport']
  res[:wagered_amount] = ln['Risk']
  LineCreator.new(res).run!
  BetUpdater.new(res).run!
end

def load_lines!
  FasterCSV.foreach("#{RAILS_ROOT}/public/cfb.csv", :headers => true) do |ln|
    load_line!(ln)
  end
end