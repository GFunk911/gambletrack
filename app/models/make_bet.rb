module FromHash
  def from_hash(ops)
    ops.each do |k,v|
      send("#{k}=",v)
    end
  end
  def initialize(ops={})
    from_hash(ops)
  end
end

class MakeBet
  include FromHash
  attr_accessor :game, :spread, :odds, :amount, :game_id
  def initialize(ops)
    puts "MakeBet #{ops.inspect}"
    from_hash(ops)
  end
  fattr(:line) do
    game.lines.select { |l| l.spread.to_closest_spread == spread.to_f.to_closest_spread and l.team_obj == game.anti_public_team }.first
  end
  fattr(:game) do
    GameSummary.new(Game.find(game_id)).tap { |g| raise "no game for game_id #{game_id}" unless g }
  end
  def make_bet
    line.make_bet(:odds => odds, :amount => amount)
  end
end
