require_relative 'condition'

def test_cond(text)
  Condition.new(
    c: 'Test',
    g: text,
  )
end

def deaths(player, qmod, n, unit)
  Condition.new(
		c: 'Deaths',
		g: player,
		u: unit,
		m: qmod,
		n: n,
    format: [:g, :u, :m, :n]
	)
end

def switchIsState(id, state)
  Condition.new(
    c: 'Switch',
    r: id,
    m: state # 'is set' or 'not set'
  )
end

def accumulate()

end
