class ConsensusLoad
  def load!
    SIConsensus.new.games.map { |x| x.pinny_spread_hash }.select { |x| valid_game?(x) }.tap { |x| puts x.size }.each { |x| ConsensusCreator.new(x).run! }
  end
  def valid_game?(h)
    #%w(NFL NHL CFB NBA CBB).include?(h[:sport])
    #h[:sport] == 'NBA' and h[:event_dt].day == Time.now.day 
    %w(NFL NHL CFB NBA CBB).include?(h[:sport]) and h[:event_dt].day == Time.now.day
  end
end