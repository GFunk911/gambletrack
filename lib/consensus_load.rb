class ConsensusLoad
  def load!
    SIConsensus.new.games.map { |x| x.pinny_spread_hash }.select { |x| %w(NFL NHL CFB NBA).include?(x[:sport]) }.each { |x| ConsensusCreator.new(x).run! }
  end
end