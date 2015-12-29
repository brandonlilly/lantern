require_relative 'data'

def format_player(player)
  str = player.to_s.downcase
  return "Player #{str.scan(/p(\d+)/)[0][0]}" if str[/p\d+/]

  player
end

def format_switch_mod(value)
  return "set" if [true, :set, "set", :true].include?(value)
  return "clear" if [false, :clear, "clear", :false].include?(value)
  return "toggle" if [:toggle, "toggle"].include?(value)

  value
end

def format_vmod(value)
  str = value.to_s.downcase
  return "Set To" if ["set to", "set_to", "set"].include?(str)
  return "Subtract" if str == 'subtract'
  return "Add" if str == 'add'

  value
end

def format_qmod(value)
  str = value.to_s.downcase
  return "At least" if ["at least", "at_least"].include?(str)
  return "At most" if ["at most", "at_most"].include?(str)
  return "Exactly" if "exactly" == str

  value
end
