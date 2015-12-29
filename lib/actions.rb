require_relative 'action'

def test_action(text)
  Action.new(
    c: "Test",
    s: text
  )
end

def display(text)
  Action.new(
    c: "Display Text Message Always",
    s: text
  )
end

def createUnit(player, unit, n, location)
  Action.new(
    c:  'Create Unit',
    gf: format_player(player),
    u:  unit,
    n:  n,
    l:  location
  )
end

def moveLocation(move_loc, player, unit, dest_loc)
  Action.new(
    c:  'Move Location',
    l:  dest_loc,
    gf: player,
    u:  unit,
    gs: move_loc,
    format: [:gf, :u, :l, :gs]
  )
end

def moveUnit(player, unit, n, at_loc, to_loc)
  Action.new(
    c:  'Move Unit',
    gf: player,
    u:  unit,
    n:  n,
    l:  at_loc,
    gs: to_loc,
    format: [:gf, :u, :n, :l, :gs]
  )
end

def setDeaths(player, vmod, n, unit)
  Action.new(
    c:  'Set Deaths',
    gf: format_player(player),
    n:  format_vmod(vmod),
    gs: n,
    u:  unit
  )
end

def setResources(player, vmod, n, resource_type)
  Action.new(
    c: 'Set Resources',
    gf: format_player(player),
    n:  format_vmod(vmod),
    gs: n,
    u:  resource_type
  )
end

def setSwitch(switch_id, value)
  Action.new(
    c: 'Set Switch',
    gs: switch_id,
    n:  format_switch_mod(value)
  )
end
