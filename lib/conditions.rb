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

def switchIsState(id, state)
  Condition.new(
    c: 'Switch',
    r: id,
    m: format_switch_state(state)
  )
end
