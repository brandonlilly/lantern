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

  def !
    conditional(inverted: true) {|cond| [
      _if(self)[ cond << true ]
    ]}
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

    if other.is_a?(Condition) || other.is_a?(Conditional) || other.class.method_defined?(:to_cond)
      return self.concat([other])
    end

    raise ArgumentError, "Expecting ConditionList or Condition: #{other}"
  end

end

class Conditional
  include AndOr

  attr_accessor :action_block, :inverted

  def initialize(options = {}, action_block)
    @action_block = action_block
    @inverted = options.fetch(:inverted, false)
  end

  def !
    clone(inverted: !inverted)
  end

  alias_method :or, :|
  def |(other)
    return self.or(other) if inverted

    old_proc = action_block
    new_block = Proc.new do |cond|
      actions = old_proc.call(cond)
      actions.concat([ _if( other )[ cond << true ] ])
    end

    self.class.new(new_block)
  end

  def clone(options = {})
    self.class.new({
      inverted: options.fetch(:inverted, inverted),
    }, action_block)
  end
end

def conditional(options = {}, &action_block)
  Conditional.new(options, action_block)
end
