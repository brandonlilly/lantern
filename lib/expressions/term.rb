require_relative 'product_expression'

module Term
  def representation
    raise NotImplementedError
  end

  def <<
    raise NotImplementedError
  end

  def cost
    raise NotImplementedError
  end

  def min
    raise NotImplementedError
  end

  def max
    raise NotImplementedError
  end

  def offset
    raise NotImplementedError
  end

  def unique
    raise NotImplementedError
  end

  def count
    raise NotImplementedError
  end

  def +(other)
    ProductExpression.new(self) + other
  end

  def -(other)
    ProductExpression.new(self) - other
  end

  def -@
    ProductExpression.new(self) * -1
  end

  def *(other)
    ProductExpression.new(self) * other
  end

  def /(other)
    raise NotImplementedError
  end

  def %(other)
    raise NotImplementedError
  end

  def **(other)
    raise NotImplementedError if !other.is_a?(Integer)
    (1..other).reduce(1) { |acc, el| acc * self }
  end

  def ==(other)
    ProductExpression.new(self) == other
  end

  def >=(other)
    ProductExpression.new(self) >= other
  end

  def <=(other)
    ProductExpression.new(self) <= other
  end

  def !=(other)
    !(self == other)
  end

  def >(other)
    self >= other + 1
  end

  def <(other)
    self <= other - 1
  end

  def <=>(other)
    representation <=> other.representation
  end
end
