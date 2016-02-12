require_relative 'helpers'
require_relative 'action'

def test_action(text)
  Action.new(
    c: "Test",
    s: text
  )
end

def centerView(location)
  Action.new(
    c: 'Center View',
    l: location
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

def createUnitWithProperties(player, unit, n, location, properties)
  raise NotImplementedError
  property_number = 0 # todo

  new Action.new(
    c:  'Create Unit with Properties',
    gf: player,
    u:  unit,
    n:  n,
    l:  location,
    gs: property_number,
  )
end

def comment(text = '')
  Action.new(
    c: 'Comment',
    s: text
  )
end

def defeat()
  Action.new(c: 'Defeat')
end

def display(text)
  Action.new(
    c: "Display Text Message Always",
    s: text
  )
end

def draw()
  Action.new(c: 'Draw')
end

def give(player, unit, n, new_owner, location)
  Action.new(
    c:  'Give Units to Player',
    gf: format_player(player),
    u:  unit,
    n:  n,
    gs: format_player(new_owner),
  )
end

def killUnit(player, unit)
  Action.new(
    c:  'Kill Unit',
    gf: format_player(player),
    u:  unit
  )
end

def killUnitAtLocation(player, unit, n, location)
  Action.new(
    c: 'Kill Unit At Location',
    gf: format_player(player),
    u:  unit,
    n:  n,
    l:  location
  )
end

def leaderboardPoints(label, score_type)
  Action.new(
    c: 'Leaderboard (Points)',
    s: label,
    u: score_type,
  )
end

def leaderboardComputers(state)
  Action.new(
    c: 'Leaderboard Computer Players',
    n: state
  )
end

def leaderboardControl(label, unit)
  Action.new(
    c: 'Leaderboard (Control)',
    s: label,
    u: unit
  )
end

def leaderboardControlAtLocation(label, unit, location)
  Action.new(
    c: 'Leaderboard (Control At Location)',
    s: label,
    u: unit,
    l: location
  )
end

def leaderboardGreed(amount)
  Action.new(
    c: 'Leaderboard (Greed)',
    gs: amount
  )
end

def leaderboardKills(label, unit)
  Action.new(
    c: 'Leaderboard (Kills)',
    s: label,
    u: unit
  )
end

def leaderboardResources(label, resource_type)
  Action.new(
    c: 'Leaderboard (Resources)',
    s: label,
    u: format_resource_type(resource_type)
  )
end

def leaderboardGoalPoints(label, score_type, amount)
  Action.new(
    c: 'Leaderboard Goal (Points)',
    s:  label,
    u:  score_type,
    gs: amount
  )
end

def leaderboardGoalControl(label, unit, amount)
  Action.new(
    c: 'Leaderboard Goal (Control)',
    s:  label,
    u:  unit,
    gs: amount
  )
end

def leaderboardGoalControlAtLocation(label, unit, location, amount)
  Action.new(
    c: 'Leaderboard Goal (Control At Location)',
    s:  label,
    u:  unit,
    gs: amount,
    l:  location
  )
end

def leaderboardGoalKills(label, unit, amount)
  Action.new(
    c: 'Leaderboard Goal (Kills)',
    s:  label,
    u:  unit,
    gs: amount
  )
end

def leaderboardGoalResources(label, resource_type, amount)
  Action.new(
    c: 'Leaderboard Goal (Resources)',
    s:  label,
    u:  resource_type,
    gs: amount
  )
end

def ping(location)
  Action.new(
    c: 'Minimap Ping',
    l: location
  )
end

def modifyHealth(player, unit, n, location, percent)
  Action.new(
    c: 'Modify Unit Hit Points',
    gf: format_player(player),
    u:  unit,
    gs: percent,
    n:  n,
    l:  location
  )
end

# consider renaming
def modifyHangar(player, unit, n, location, amount_to_add)
  Action.new(
    c: 'Modify Unit Hangar Count',
    gf: format_player(player),
    u:  unit,
    gs: amount_to_add,
    n:  n,
    l:  location
  )
end

def modifyEnergy(player, unit, n, location, percent)
  Action.new(
    c: 'Modify Unit Energy',
    gf: player,
    u: unit,
    gs: percent,
    n: n,
    l: location
  )
end

# consider renaming
def modifyResource(player, num_sources, amount, location)
  Action.new(
    c: 'Modify Unit Resource Amount',
    gf: format_player(player),
    gs: amount,
    n:  num_sources,
    l:  location
  )
end

def modifyShield(player, unit, n, location, percent)
  Action.new(
    c: 'Modify Unit Shield Points',
    gf: format_player(player),
    u:  unit,
    gs: percent,
    n:  n,
    l:  location
  )
end

def moveLocation(move_loc, player, unit, dest_loc)
  Action.new(
    c:  'Move Location',
    gf: player,
    u:  unit,
    l:  dest_loc,
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

def mute()
  Action.new(c: 'Mute Unit Speech')
end

def order(player, unit, at_loc, order, to_loc)
  Action.new(
    c: 'Order',
    gf: player,
    u:  unit,
    l:  at_loc,
    gs: to_loc,
    n:  order
  )
end

def pauseGame()
  Action.new(c: 'Pause Game')
end

def pauseTimer()
  Action.new(c: 'Pause Timer')
end

def preserveTrigger()
  Action.new(c: 'Preserve Trigger')
end

def removeUnit(player, unit)
  Action.new(
    c: 'Remove Unit',
    gf: format_player(player),
    u:  unit
  )
end

def removeUnitAtLocation(player, unit, n, location)
  Action.new(
    c: 'Remove Unit At Location',
    gf: player,
    u:  unit,
    n:  n,
    l:  location
  )
end

def runAIScript(script)
  Action.new(
    c: 'Run AI Script',
    gs: script # todo: format script
  )
end

def runAIScriptLocation(script, location)
  Action.new(
    c: 'Run AI Script At Location',
    gs: script, # todo: format script
    l:  location
  )
end

def setAlliance(player, ally_status)
  Action.new(
    c: 'Set Alliance Status',
    gf: format_player(player),
    u:  ally_status # todo: format status
  )
end

def setDoodadState(player, unit, location, state)
  Action.new(
    c: 'Set Doodad State',
    gf: format_player(player),
    u:  unit,
    l:  location,
    n:  state # todo: format state (different for minting)
  )
end

def setCountdownTimer(vmod, seconds)
  Action.new(
    c: 'Set Countdown Timer',
    n: format_vmod(vmod),
    t: seconds
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

def setInvincibility(player, unit, location, state)
  Action.new(
    c: 'Set Invincibility',
    gf: format_player(player),
    u:  unit,
    l:  location,
    n:  state # todo: format (different for mint)
  )
end

def setMissionObjectives(text)
  Action.new(
    c: 'Set Mission Objectives',
    s: text
  )
end

def setResources(player, vmod, n, resource_type)
  Action.new(
    c: 'Set Resources',
    gf: format_player(player),
    n:  format_vmod(vmod),
    gs: n,
    u:  format_resource_type(resource_type)
  )
end

def setScore(player, vmod, n, score_type)
  Action.new(
    c: 'Set Score',
    gf: format_player(player),
    n:  format_vmod(vmod),
    gs: n,
    u:  score_type # todo: format score type
  )
end

def setSwitch(switch_id, value)
  Action.new(
    c: 'Set Switch',
    gs: switch_id,
    n:  format_switch_mod(value)
  )
end

def talkingPortrait(unit, ms)
  Action.new(
    c: 'Talking Portrait',
    u: unit,
    t: ms
  )
end

def transmission(text, unit, location, wav_path)
  Action.new(
    c: 'Transmission',
    s:  text,
    u:  unit,
    l:  location,
    n:  'Subtract',
    t:  0,
    w:  wav_path
  )
end

def unmute()
  Action.new(c: 'Unmute Unit Speech')
end

def unpauseGame()
  Action.new(c: 'Unpause Game')
end

def unpauseTimer()
  Action.new(c: 'Unpause Timer')
end

def victory()
  Action.new(c: 'Victory')
end

def wait(ms)
  Action.new(
    c: 'Wait',
    t: ms
  )
end
