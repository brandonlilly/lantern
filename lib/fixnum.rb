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

  def +(other)
    return other + self if other.is_a?(Counter)
    self.add(other)
  end

  def -(other)
    return -other + self if other.is_a?(Counter)
    self.sub(other)
  end

  def *(other)
    return other * self if other.is_a?(Counter)
    self.mult(other)
  end

  def /(other)
    if other.is_a?(Counter)
      dc = Counter.new;
      return [
        dc << self,
        dc / other,
      ]
    end

    self.div(other)
  end

  def %(other)
    if other.is_a?(Counter)
      dc = Counter.new;
      return [
        dc << self,
        dc % other,
      ]
    end

    self.modu(other)
  end

  def **(other)
    raise NotImplementedError if other.is_a?(Counter) # todo
    self.pow(other)
  end

  def ==(other)
    return other == self if other.is_a?(Counter)
    self.eql(other)
  end

  def >=(other)
    return other <= self if other.is_a?(Counter)
    self.gte(other)
  end

  def <=(other)
    return other >= self if other.is_a?(Counter)
    self.lte(other)
  end

  def >(other)
    return other < self if other.is_a?(Counter)
    self.lt(other)
  end

  def <(other)
    return other > self if other.is_a?(Counter)
    self.gt(other)
  end

end
