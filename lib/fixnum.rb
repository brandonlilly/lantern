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
    return other + self if is_known?(other)
    self.add(other)
  end

  def -(other)
    return -other + self if is_known?(other)
    self.sub(other)
  end

  def *(other)
    return other * self if is_known?(other)
    self.mult(other)
  end

  def /(other)
    raise NotImplementedError if is_known?(other)
    self.div(other)
  end

  def %(other)
    raise NotImplementedError if is_known?(other)
    self.modu(other)
  end

  def **(other)
    raise NotImplementedError if is_known?(other)
    self.pow(other)
  end

  def ==(other)
    return other == self if is_known?(other)
    self.eql(other)
  end

  def !=(other)
    return other != self if is_known?(other)
    self.neq(other)
  end

  def >=(other)
    return other <= self if is_known?(other)
    self.gte(other)
  end

  def <=(other)
    return other >= self if is_known?(other)
    self.lte(other)
  end

  def >(other)
    return other < self if is_known?(other)
    self.gt(other)
  end

  def <(other)
    return other > self if is_known?(other)
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

  private

  def is_known?(other)
    other.is_a?(Counter) || other.is_a?(Switch) || other.is_a?(Expression)
  end

end
