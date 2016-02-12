require_relative '../counters/counter'

class Expression
  attr_accessor :constant, :list

  def initialize(other)
    other.is_a?(Integer) ?
      [ self.constant = other, self.list = [] ] :
      [ self.constant = constant_default, self.list = [other] ]
    simplify
  end

  def symbol
    raise NotImplementedError
  end

  def constant_default
    raise NotImplementedError
  end

  def -(other)
    self + -other
  end

  def -@
    self * -1
  end

  def ==(other)
    compare(other, :exactly)
  end

  def >=(other)
    compare(other, :atLeast)
  end

  def <=(other)
    compare(other, :atMost)
  end

  def >(other)
    self >= other + 1
  end

  def <(other)
    self <= other - 1
  end

  def !=(other)
    !(self == other)
  end

  def <=>(other)
    representation <=> other.representation
  end

  def count(other)
    list.reduce(0) { |acc, el| acc += el.count(other) }
  end

  def unique
    list.map(&:unique).flatten.uniq.sort
  end

  def insert(other)
    list << other
  end

  def simplify
    raise NotImplementedError
  end

  def cost
    list.map(&:cost).reduce(symbol)
  end

  def offset
    list.reduce(constant) { |acc, el| acc.send(symbol, el.offset) }
  end

  def representation
    "(" + list.map(&:representation).join(symbol.to_s) + ")"
  end

  def to_s
    "(" + [constant].concat(list).join(symbol.to_s) + ")"
  end

  private

  def compare(other, symbol)
    diff = self - other

    # immediately evaluate expression if constant numbers
    if diff.list.empty?
      return never if (symbol == :exactly && diff.constant != 0) ||
                      (symbol == :atLeast && diff.constant < 0)  ||
                      (symbol == :atMost && diff.constant > 0)
      return []
    end

    # immediately evaluate expression if there is only one counter
    varList = diff.unique
    if varList.length == 1 && diff.count(varList.first) == 1 && varList.first.is_a?(Counter)
      product = diff.list.first
      counter = product.list.first
      quotient = -diff.constant / product.constant
      remainder = -diff.constant % product.constant
      return never if symbol == :exactly && remainder != 0
      return counter.send(symbol, quotient)
    end

    # evaluate the function for multiple counters
    conditional do |cond|
      temp = DC.new
      [
        temp << diff,
        cond << temp.send(symbol, 0), #_if(temp.send(symbol, 0)) [cond << true],
        temp << 0,
      ]
    end
  end
end
