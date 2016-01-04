class Grouping
  attr_accessor :constant, :list

  def initialize(other)
    self.list = [other]
    self.constant = constant_default

    post_initialize(other)
  end

  def post_initialize(other)
    nil
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

  def insert(other)
    list << other
    list.sort!
    self
  end

  def <=>(other)
    cost == other.cost ?
      (representation < other.representation ? -1 : 1) :
      (cost < other.cost ? -1 : 1)
  end

  def cost
    list.map(&:cost).reduce(symbol)
  end

  def representation
    "(" + list.map(&:representation).join(symbol.to_s) + ")"
  end

  def to_s
    "(" + [constant].concat(list).join(symbol.to_s) + ")"
  end

end

class Product < Grouping
  def constant_default
    1
  end

  def symbol
    :*
  end

  def +(other)
    Sum.new(self) + other
  end

  def *(other)
    other = Product.new(other) if other.is_a?(Counter)
    if other.is_a?(Integer)
      return 0 if other == 0
      self.constant *= other
    elsif other.is_a?(Sum)
      insert(other)
    elsif other.is_a?(Product)
      other.list.each {|elem| insert(elem)}
    else
      raise ArgumentError, "Input needs to be an Integer, Counter, Sum, or Product"
    end
    self
  end

  def contains?(other)
    return 1 if list.length == 1 && list.first.representation == other.representation && constant == 1
    return 2 if list.any? { |elem| elem.representation == other.representation }
    0
  end
  def remove_self(other)
    list.delete(other)
    list.length == 0
  end

  def evaluateInto(other)
    raise NotImplementedError if list.length > 1
    actions = []
    list.each { |elem| actions << elem.countoff(other, constant) }
    actions
  end

  def offset
    list.reduce(constant) { |acc, el| acc *= el.min }
  end
  def minAndMax
    minval = constant
    maxval = constant
    list.each do |elem|
      arr = [minval * elem.min, minval * elem.max, maxval * elem.min, maxval * elem.max]
      minval = arr.min
      maxval = arr.max
    end
    {min: minval, max: maxval}
  end
  def min
    minAndMax[:min]
  end
  def max
    minAndMax[:max]
  end
  def step
    list.reduce(constant) { |acc, el| acc *= el.step }.abs
  end
end

class Sum < Grouping
  def constant_default
    0
  end

  def symbol
    :+
  end

  def +(other)
    other = Product.new(other) if other.is_a?(Counter)
    if other.is_a?(Integer)
      self.constant += other
    elsif other.is_a?(Product)
      insert(other)
    elsif other.is_a?(Sum)
      self.constant += other.constant
      other.list.each {|elem| insert(elem)}
    else
      raise ArgumentError, "Input needs to be an Integer, Counter, Sum, or Product"
    end
    list.length == 0 ? constant : self
  end

  def *(other)
    if other.is_a?(Integer)
      return 0 if other == 0
      self.constant *= other
      list.each {|elem| elem.constant *= other}
      return self
    end
    Product.new(self) * other
  end

  def insert(other)
    (0...list.length).each do |i|
      item = list[i]
      if item.representation == other.representation
        item.constant += other.constant
        list.delete_at(i) if item.constant == 0
        return self
      end
    end
    list << other
    list.sort!
    self
  end

  def contains_none?(other)
    list.reduce(0) { |acc, el| acc += el.contains?(other) } == 0
  end
  def contains_self?(other)
    list.reduce(0) { |acc, el| acc += el.contains?(other) } == 1
  end
  def remove_self(other)
    (0...list.length).each do |i|
      item = list[i]
      list.delete_at(i) if item.remove_self(other)
    end
  end

  def evaluateInto(other)
    actions = []
    list.each { |elem| actions << elem.evaluateInto(other) }
    actions
  end

  def offset
    list.reduce(constant) { |acc, el| acc += el.offset }
  end
  def min
    list.reduce(constant) { |acc, el| acc += el.min }
  end
  def max
    list.reduce(constant) { |acc, el| acc += el.max }
  end
  def step
    return 1 if list.length == 0
    return list.first.step if list.length == 1
    list.map(&:step).gcd
  end
end
