require 'byebug'

class Grouping
  attr_accessor :constant, :list

  def initialize(other)
    if other.is_a?(Integer)
      self.list = []
      self.constant = other
    else
      self.list = [other]
      self.constant = constant_default
      simplify
    end

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

  def ==(other)
    compare(other, :==)
  end

  def !=(other)
    compare(other, :!=)
  end

  def >(other)
    compare(other, :>)
  end

  def <(other)
    compare(other, :<)
  end

  def >=(other)
    compare(other, :>=)
  end

  def <=(other)
    compare(other, :<=)
  end

  def compare(other, symbol)
    return Product.new(self).compare(other, symbol) if !self.is_a?(Sum) && !self.is_a?(Product)
    return Sum.new(self).compare(other, symbol) if !self.is_a?(Sum)
    other = Product.new(other) if !other.is_a?(Sum) && !other.is_a?(Product)
    other = Sum.new(other) if !other.is_a?(Sum)
    # TODO: put in Conditional / Compare / Assignment class
  end

  def count(other)
    debugger
    list.reduce(0) { |acc, el| acc + el.count(other) }
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

  def simplify
    raise NotImplementedError
  end

  def cost
    list.map(&:cost).reduce(symbol)
  end

  def offset
    list.reduce(constant) { |acc, el| acc.send(symbol, el.min) }
  end

  def representation
    "(" + list.map(&:representation).join(symbol.to_s) + ")"
  end

  def to_s
    "(" + [constant].concat(list).join(symbol.to_s) + ")"
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
    other = Product.new(other) if !other.is_a?(Sum) && !other.is_a?(Product)
    other = Sum.new(other) if !other.is_a?(Sum)
    self.constant += other.constant
    other.list.each {|el| insert(el)}
    simplify
    self
  end

  def *(other)
    if other.is_a?(Integer)
      return 0 if other == 0
      self.constant *= other
      list.each {|el| el.constant *= other}
      return self
    end
    Product.new(self) * other
  end

  def insert(other)
    list.each do |el|
      if el.representation == other.representation
        el.constant += other.constant
        other = []
        break
      end
    end
    list << other
    simplify
    self
  end

  def contains_self?(other)
    count(other) == 1 && list.any? { |el| el.contains_self?(other) }
  end

  def generate(other)
    list.map { |el| el.generate(other) }
  end

  def remove(other)
    list.each { |el| el.remove(other) }
    simplify
  end

  def simplify
    self.constant += list.select {|el| el.list.empty?}.map(&:constant).reduce(0, :+)
    list.reject! { |el| el.list.empty? || el.constant == 0 }
    list.sort!
  end

  def min
    list.reduce(constant) { |acc, el| acc += el.min }
  end

  def max
    list.reduce(constant) { |acc, el| acc += el.max }
  end

  def step
    list.empty? ? 1 : list.reduce(list.first.step) { |acc, el| acc.gcd(el.step) }
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
    other = Product.new(other) if !other.is_a?(Product)
    self.constant *= other.constant
    other.list.each {|el| insert(el)}
    simplify
    self
  end

  def contains_self?(other)
    list.length == 1 && list.first.representation == other.representation && constant == 1
  end

  def generate(other)
    raise NotImplementedError if list.length > 1
    actions = []
    list.each { |el| actions << el.countoff(other, constant) }
    actions
  end

  def remove(other)
    self.constant = 0 if representation == other.representation
    list.delete(other)
    list.each { |el| el.remove(other) }
    simplify
  end

  def simplify
    # self.constant *= list.select { |el| el.list.empty? }.map(&:constant).reduce(:*)
    # list.reject! { |el| el.list.empty? }
    list.sort!
  end

  def minAndMax
    minval, maxval = constant, constant
    list.each do |el|
      arr = [minval * el.min, minval * el.max, maxval * el.min, maxval * el.max]
      minval, maxval = arr.min, arr.max
    end
    {min: minval, max: maxval}
  end

  def bounds
    list.reduce([constant, constant]) do |acc, el|
      bounds = [ acc.min * el.min, acc.min * el.max, acc.max * el.min, acc.max * el.max ]
      {min: bounds.min, max: bounds.max}
    end
  end

  def min
    bounds[:min]
    minAndMax[:min]
  end

  def max
    bounds[:max]
    minAndMax[:max]
  end

  def step
    list.reduce(constant) { |acc, el| acc *= el.step }.abs
  end
end
