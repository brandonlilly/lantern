module AndOr

  def |(other)
    conditional {|cond| [
      _if(self)[ cond << true ],
      _if(other)[ cond << true ],
    ]}
  end

  def &(other)
    ConditionList.new.concat([self, other])
  end
end


class Condition
  include AndOr

  attr_accessor :params

  def initialize(options)
    @params = {
      c: options[:c],
      g: options[:g],
      u: options[:u],
      m: options[:m],
      n: options[:n],
      r: options[:r],
    }
  end

  def render
    param_render = params.keys.compact
      .select { |key| key != :c && !params[key].nil? }
      .map {|key| "#{key}: #{params[key]}"}
      .join(', ')
    "<Condition #{params[:c]} (#{param_render})>"
  end

  def render_xml
    param_tags = params
      .reject { |key| params[key].nil? }
      .map { |key, value| "  <cond_#{key}>#{value}</cond_#{key}>" }
      .join("\n")

    "<condition>\n#{param_tags}\n</condition>"
  end

  def type
    params[:c]
  end

  def to_cond
    self
  end
end

class ConditionList < Array
  include AndOr

  alias_method :intersection, :&
  alias_method :union,        :|

  def &(other)
    if other.is_a?(ConditionList)
      return self + other
    end

    if other.is_a?(Condition) || other.class.method_defined?(:to_cond)
      return self << other
    end

    abort("Unknown parameter: #{other}")
  end
end

class Conditional
  include AndOr

  attr_accessor :actions, :action_block

  def initialize(action_block)
    @action_block = action_block
  end

  def *(other)
    ->(*args) { self[*other[*args]] }
  end

  def |(other)
    old_proc = action_block
    new_block = Proc.new do |cond|
      actions = old_proc.call(cond)
      actions.concat([ _if( other )[ cond << true ] ])
    end

    Conditional.new(new_block)
  end
end

def conditional(&action_block)
  Conditional.new(action_block)
end

# conditions

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

def test_cond(text)
  Condition.new(
    c: 'Test',
    g: text,
  )
end
