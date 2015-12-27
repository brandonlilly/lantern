class Action
  attr_accessor :params

  def initialize(options)
    @params = {
      c:  options[:c],
      gf: options[:gf],
      n:  options[:n],
      gs: options[:gs],
      u:  options[:u],
      s:  options[:s],
      l:  options[:l],
    }
  end

  def render
    param_render = params.keys.compact
      .select { |key| key != :c && !params[key].nil? }
      .map {|key| "#{key}: #{params[key]}"}
      .join(", ")
    "<Action #{params[:c]} (#{param_render})>"
  end

  def type
    params[:c]
  end
end

def display(text)
  Action.new(
    c: "Display Text Message Always",
    s: text
  )
end

def setDeaths(player, vmod, n, unit)
  Action.new(
    c:  'Set Deaths',
    gf: player,
    n:  vmod,
    gs: n,
    u:  unit
  )
end

def setSwitch(switch_id, value)
  Action.new(
    c: 'Set Switch',
    gs: switch_id,
    n:  value # convert to cleared, not set, ect
  )
end

def createUnit(player, unit, n, location)
  Action.new(
    c:  'Create Unit',
    gf: player,
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
