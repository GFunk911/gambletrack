module GLCreator
  attr_accessor :h
  def initialize(h)
    @h = h
  end
  fattr(:event_dt) { h[:event_dt] }
  fattr_nn(:sport) do
    Sport.find_by_abbr(h[:sport])
  end
  def team(t)
    t = $1.strip if t and t =~ /^(.*)\(.*\)/ and h[:sport] == 'MLB'
    sport.find_team(t)#.tap { |x| raise "no team found for #{t}" unless x and t }
  end
  fattr_nn(:home_team) { team(h[:home_team]) }
  fattr_nn(:away_team) { team(h[:away_team]) }
  fattr_nn(:period) do
    event_dt ? sport.periods.all_containing(event_dt).first : Period.find(6)
  end
  def pretty_dt
    event_dt ? event_dt.pretty_dt : ""
  end
  fattr(:existing_game) do
    begin
      sport.games.find(:all, :conditions => {:period_id => period.id, :home_team_id => home_team.id, :away_team_id => away_team.id}).select { |x| x.event_dt.day == event_dt.day }.first
    rescue => exp
      puts "could not find existing game for #{h.inspect}"
      raise exp
    end
  end
end

module LineUpdate
  fattr(:existing_line) do 
    game.lines.select do |x| 
      x.spread.to_closest_spread == spread and x.odds.to_s == odds.to_s and x.team_obj == selected_team and x.site_id == site.id and (x.bet_type == bet_type or !bet_type)
    end.first
  end
  fattr_nn(:site) do
    Site.find(:first, :conditions => {:name => h[:site]})
  end
  fattr_nn(:selected_team) { team(h[:team]) }
  def odds
    Gambling::Odds.get(h[:odds])
  end
  def spread
     h[:spread].to_closest_spread
  end
  fattr_nn(:game) { existing_game }
  fattr(:bet_type) do
    h[:bet_type] ? Line.get_bet_type(h[:bet_type]) : nil
  end
end

class GameUpdater
  include GLCreator
  def run!
    unless sport_cbn and home_team_cbn and away_team_cbn and existing_game
      puts "no game for #{h.inspect}" if %w(NFL NHL MLB CFB).include?(h[:sport])
      return
    end
    puts "making game for #{h.inspect}"
    existing_game.home_score ||= h[:home_score]
    existing_game.away_score ||= h[:away_score]
    existing_game.save!
  end
end

class BetUpdater
  include GLCreator
  include LineUpdate
  def game
    existing_game
  end
  def run!
    unless sport_cbn and home_team_cbn and away_team_cbn and existing_game
      puts "no game for #{h.inspect}" if %w(NFL NHL MLB CFB).include?(h[:sport])
      return
    end
    puts "making bet for #{h.inspect}"
    existing_line.wagered_amount = h[:wagered_amount].to_f
    existing_line.save!
  end
end

class GameCreator
  include GLCreator
  fattr(:new_game) do
    sport.games.new(:period_id => period.id, :home_team_id => home_team.id, :away_team_id => away_team.id, :event_dt => event_dt).tap { |x| x.save! }
  end
  fattr(:desc) { "#{away_team}@#{home_team} #{pretty_dt}" }
  def run!
    puts(existing_game ? "Found #{desc}" : "Creating #{desc}")
    existing_game || new_game
  end
end

class LineCreator
  include GLCreator
  include LineUpdate


  fattr(:effective_dt) { h[:effective_dt] || Time.now }
  fattr(:new_line) do 
    game.lines.new(:team_id => selected_team.id, :return_from_dollar => odds.rfd, :spread => spread, :site => site, :bet_type => bet_type, :effective_dt => effective_dt).tap { |x| x.save! }
  end
  fattr(:desc) do
    "#{away_team}@#{home_team} #{selected_team} #{bet_type} #{spread} #{odds} #{pretty_dt}"
  end
  def run!
    #return unless away_team.abbr == 'STL'
    puts(existing_line ? "Found #{desc}" : "Creating #{desc}")
    existing_line || new_line
  end
end

class ConsensusCreator
  attr_accessor :h
  def initialize(h)
    @h = h
  end
  fattr(:line) { Line.find_or_create_from_hash(h) }
  def run!
    line.add_consensus(h)
  rescue => exp
    puts "no game " + exp.message
  end
end