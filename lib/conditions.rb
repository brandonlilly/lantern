require_relative 'helpers'
require_relative 'condition'

def test_cond(text)
  Condition.new(
    c: 'Test',
    g: text,
  )
end

def accumulate(player, qmod, n, resource_type)
  Condition.new(
    c: 'Accumulate',
    g: format_player(player),
    m: format_qmod(qmod),
    n: n,
    r: format_resource_type(resource_type),
  )
end

def bring(player, unit, qmod, n, location)
  Condition.new(
    c: 'Bring',
    g: format_player(player),
    u: unit,
    m: format_qmod(qmod),
    n: n,
    l: location
  )
end

def command(player, unit, qmod, n, location)
  Condition.new(
    c: 'Command',
    g: format_player(player),
    u: unit,
    m: format_qmod(qmod),
    n: n
  )
end

def commandTheLeast(unit)
  Condition.new(
    c: 'Command the Least',
    u: unit
  )
end

def commandTheLeastAt(unit, location)
  Condition.new(
    c: 'Command the Least At',
    u: unit,
    l: location
  )
end

def commandTheMost(unit)
  Condition.new(
    c: 'Command the Most',
    u: unit
  )
end

def commandTheMostAt(unit, location)
  Condition.new(
    c: 'Command the Most At',
    u: unit,
    l: location
  )
end

def countdownTimer(qmod, seconds)
  Condition.new(
    c: 'Countdown Timer',
    m: format_qmod(qmod),
    n: seconds
  )
end

def deaths(player, qmod, n, unit)
  Condition.new(
		c: 'Deaths',
		g: format_player(player),
		u: unit,
		m: format_qmod(qmod),
		n: n,
    format: [:g, :u, :m, :n]
	)
end

def elapsed(qmod, seconds)
  Condition.new(
    c: 'Elapsed Time',
    m: format_qmod(qmod),
    n: seconds
  )
end

def highestScore(score_type)
  Condition.new(
    c: 'Highest Score',
    r: score_type
  )
end

def killsOf(player, unit, qmod, n)
  Condition.new(
    c: 'Kill',
    g: format_player(player),
    u: unit,
    m: format_qmod(qmod),
    n: n,
    format: [:g, :u, :m, :n]
  )
end

def leastKills(unit)
  Condition.new(
    c: 'Least Kills',
    u: unit
  )
end

def leastResources(unit)
  Condition.new(
    c: 'Least Resources',
    r: format_resource_type(resource_type)
  )
end

def lowestScore(score_type)
  Condition.new(
    c: 'Lowest Score',
    r: score_type
  )
end

def mostKills(unit)
  Condition.new(
    c: 'Most Kills',
    u: unit
  )
end

def mostResources(unit)
  Condition.new(
    c: 'Most Resources',
    r: format_resource_type(resource_type)
  )
end

def never()
  Condition.new(
    c: 'Never'
  )
end

def opponents(player, qmod, n)
  Condition.new(
    c: 'Opponents',
    g: format_player(player),
    m: format_qmod(qmod),
    n: n
  )
end

def switchIsState(id, state)
  Condition.new(
    c: 'Switch',
    r: id,
    m: format_switch_state(state)
  )
end

def score(player, score_type, qmod, n)
  Condition.new(
    c: 'Score',
    g: format_player(player),
    r: score_type,
    m: qmod,
    n: n
  )
end

# custom

def memory(player_number, qmod, n)
  Condition.new(
    c: 'Memory',
    g: player_number,
    # u: 0
    m: format_qmod(qmod),
    n: n
  )
end
