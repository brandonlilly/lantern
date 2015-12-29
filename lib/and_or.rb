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

    raise ArgumentError, "Expecting ConditionList or Condition: #{other}"
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
