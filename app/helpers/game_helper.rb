module GameHelper
  def line_table_cols(lines)
    res = []
    res << 'Game' if lines.respond_to?(:games)
    res += %w(Team Site Spread Odds Desired Outstanding Wagered Expired Time)
    game = lines.respond_to?(:games) ? games.first : lines
    res << 'Status' if game.played?
    res
  end
end
