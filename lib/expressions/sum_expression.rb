require_relative 'product_expression'
require_relative 'expression'

class SumExpression < Expression
  def constant_default
    0
  end

  def symbol
    :+
  end

  def +(other)
    other = ProductExpression.new(other) if !other.is_a?(SumExpression) && !other.is_a?(ProductExpression)
    other = SumExpression.new(other) if !other.is_a?(SumExpression)
    self.constant += other.constant
    other.list.each { |el| insert(el) }
    simplify
    self
  end

  def *(other)
    return ProductExpression.new(self) * other if !other.is_a?(Integer)
    return 0 if other == 0
    self.constant *= other
    list.each {|el| el.constant *= other}
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
    self.constant += list.select { |el| el.list.empty? }.map(&:constant).reduce(0, :+) # TODO: problematic for dc1 << dc2
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
    list.empty? ? 1 : list.reduce(list.first.step) { |acc, el| acc = acc.gcd(el.step) }
  end

  private

  def insert(other)
    if matching = list.find { |el| el.representation == other.representation }
      matching.constant += other.constant
    else
      list << other
    end
  end
end
