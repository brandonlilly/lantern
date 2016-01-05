class Fixnum
  alias_method :add,  :+
  alias_method :sub,  :-
  alias_method :mult, :*
  alias_method :div,  :/
  alias_method :modu, :%
  alias_method :pow,  :**
  alias_method :gte, :>=
  alias_method :lte, :<=
  alias_method :lt,  :<
  alias_method :gt,  :>
  alias_method :eql, :==
  alias_method :neq, :!=

  def +(other)
    return other + self if other.is_a?(Counter) || other.is_a?(Grouping)
    self.add(other)
  end

  def -(other)
    return -other + self if other.is_a?(Counter) || other.is_a?(Grouping)
    self.sub(other)
  end

  def *(other)
    return other * self if other.is_a?(Counter) || other.is_a?(Grouping)
    self.mult(other)
  end

  def /(other)
    raise NotImplementedError if other.is_a?(Counter) || other.is_a?(Grouping)
    self.div(other)
  end

  def %(other)
    raise NotImplementedError if other.is_a?(Counter) || other.is_a?(Grouping)
    self.modu(other)
  end

  def **(other)
    raise NotImplementedError if other.is_a?(Counter) || other.is_a?(Grouping)
    self.pow(other)
  end

  def ==(other)
    return other == self if other.is_a?(Counter) || other.is_a?(Grouping)
    self.eql(other)
  end

  def !=(other)
    return other != self if other.is_a?(Counter) || other.is_a?(Grouping)
    self.neq(other)
  end

  def >=(other)
    return other <= self if other.is_a?(Counter) || other.is_a?(Grouping)
    self.gte(other)
  end

  def <=(other)
    return other >= self if other.is_a?(Counter) || other.is_a?(Grouping)
    self.lte(other)
  end

  def >(other)
    return other < self if other.is_a?(Counter) || other.is_a?(Grouping)
    self.gt(other)
  end

  def <(other)
    return other > self if other.is_a?(Counter) || other.is_a?(Grouping)
    self.lt(other)
  end

  def min
    self
  end

  def max
    self
  end

  def cost
    0
  end

end
