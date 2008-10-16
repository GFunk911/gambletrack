module GameHelper
  def line_table_cols(lines)
    res = []
    res << 'Game' if lines.respond_to?(:games)
    res += %w(Team Site Spread Odds Desired Outstanding Wagered Expired Time)
    game = lines.respond_to?(:games) ? games.first : lines
    res << 'Status' if game.played?
    res
  end
  def game_spread_games(obj)
    if obj.is_a?(Period) and %w(NFL CFB).include?(obj.sport.abbr)
      obj.games.select { |x| x.spread_gap? }.sort_by { |x| x.spread_gap.abs }.reverse 
    elsif obj.is_a?(Game) and %w(NFL CFB).include?(obj.sport.abbr)
      return [obj]
    else
      nil
    end
  end
end
