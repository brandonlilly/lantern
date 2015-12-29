require_relative 'data'

def format_player(player)
  str = player.to_s.downcase
  return "Player #{str.scan(/(\d+)$/)[0][0]}" if str[/p\d+$/] || str[/player ?\d+$/]
  return "Force #{str.scan(/(\d+)$/)[0][0]}" if str[/f\d+/] || str[/force ?\d+$/]
  return "All players" if ['allplayers', 'all players', 'all_players'].include?(str)
  return "Neutral Players" if ['neutral_players', 'neutral players'].include?(str)
  return "Current Player" if ['current player', 'cp', 'current'].include?(str)
  return 'Allies' if str == 'allies'
  return 'Foes' if str == 'foes'
  return 'Player 12' if str == 'neutral'

  player
end

def format_switch_mod(value)
  str = value.to_s.downcase
  return "set" if ["set", "true"].include?(str)
  return "clear" if ["false", "clear", :false].include?(str)
  return "toggle" if "toggle" == str

  value
end

def format_vmod(value)
  str = value.to_s.downcase
  return "Set To" if ["set to", "set_to", "set", "setto"].include?(str)
  return "Subtract" if str == 'subtract'
  return "Add" if str == 'add'

  value
end

def format_qmod(value)
  str = value.to_s.downcase
  return "At least" if ["at least", "at_least", "atleast"].include?(str)
  return "At most" if ["at most", "at_most", "atmost"].include?(str)
  return "Exactly" if "exactly" == str

  value
end
