# altered Fixnum class
class Fixnum

  # alias functions
  alias_method :add,  :+
  alias_method :sub,  :-
  alias_method :mult, :*
  alias_method :div,  :/
  alias_method :modu, :%
  alias_method :pow,  :**

  # implement functions
  def +(arg)
    if arg.is_a?(DC)
      return arg + self
    end
    self.add(arg)
  end

  def -(arg)
    if arg.is_a?(DC)
      return -arg + self
    end
    self.sub(arg)
  end

  def *(arg)
    if arg.is_a?(DC)
      return arg * self
    end
    self.mult(arg)
  end

  def /(arg)
    if arg.is_a?(DC)
      dc = DC.new;
      return [
        dc << self,
        dc / arg,
      ]
    end
    self.div(arg)
  end

  def %(arg)
    if arg.is_a?(DC)
      dc = DC.new;
      return [
        dc << self,
        dc % arg,
      ]
    end
    self.modu(arg)
  end

  def **(arg)
    if arg.is_a?(DC)
      raise "EXPONENTIAL NOT IMPLEMENTED"
    end
    self.pow(arg)
  end

end
