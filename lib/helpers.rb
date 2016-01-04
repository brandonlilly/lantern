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

def format_switch_state(value)
  str = value.to_s.downcase
  return "is set" if ["is set", "set", "is_set", "isset", "true"].include?(str)
  return "not set" if ["clear", "not set", "not_set", "notset", "false"].include?(str)

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

def format_resource_type(value)
  str = value.to_s.downcase
  return "ore" if ['ore', 'minerals'].include?(str)
  return "gas" if ['gas', 'vespene', 'vespene gas', 'vespenegas'].include?(str)
  return "ore and gas" if ["ore and gas", "oreandgas", "both"].include?(str)

  value
end
