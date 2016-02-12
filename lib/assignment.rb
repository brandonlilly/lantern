require_relative 'expressions/sum_expression'
require_relative 'expressions/product_expression'
require_relative 'counters/counter'
require_relative 'switch'

class Assignment
  attr_accessor :object, :expression

  def initialize(object, expression)
    object = prepare_object(object)
    expression = prepare_expression(expression)

    self.object = object
    self.expression = expression
  end

  def prepare_object(object)
    raise NotImplementedError
  end

  def prepare_expression(expression)
    raise NotImplementedError
  end

  def virtual
    raise NotImplementedError
  end

  def generate
    raise NotImplementedError
  end

  def to_s
    "Assignment(" + object.to_s + "=" + expression.to_s + ")"
  end
end


class CounterAssignment < Assignment
  def prepare_object(object)
    raise ArgumentError if !object.is_a?(Counter)
    object
  end

  def prepare_expression(expression)
    expression = ProductExpression.new(expression) if !expression.is_a?(SumExpression) && !expression.is_a?(ProductExpression)
    expression = SumExpression.new(expression) if !expression.is_a?(SumExpression)
    expression
  end

  def virtual
    object.modifyBounds(min: expression.min, max: expression.max, step: expression.step)
    []
  end

  def generate
    actions = []
    if expression.count(object) == 0
      actions << object.setTo(expression.offset)
      actions << expression.generate(object)
    elsif expression.contains_self?(object)
      expression.remove(object)
      actions << object.add(expression.offset)
      actions << expression.generate(object)
    else
      temp = DC.new
      actions << temp << other
      actions << object << temp
    end
    object.modifyBounds(min: expression.min, max: expression.max, step: expression.step)
    actions
  end
end


class SwitchAssignment < Assignment
  def prepare_object(object)
    raise ArgumentError if !object.is_a?(Switch)
    object
  end

  def prepare_expression(expression)
    expression
  end

  def &(other)
    expression &= other
    self
  end

  def |(other)
    expression |= other
    self
  end

  def virtual
    []
  end

  def generate
    return object.setState(expression) if expression.is_a?(TrueClass) || expression.is_a?(FalseClass)
    [
      object << false,
      _if( expression )[
        object << true
      ],
    ]
  end
end
