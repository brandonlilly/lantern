require_relative 'expression'
require_relative 'other_expression'
require_relative 'sum_expression'

class ProductExpression < Expression
  def constant_default
    1
  end

  def symbol
    :*
  end

  def +(other)
    SumExpression.new(self) + other
  end

  def *(other)
    other = ProductExpression.new(other) if !other.is_a?(ProductExpression)
    self.constant *= other.constant
    other.list.each { |el| insert(el) }
    simplify
    self
  end

  def contains_self?(other)
    list.length == 1 && list.first.representation == other.representation && constant == 1
  end

  def generate(other)
    raise NotImplementedError if list.length > 1

    triggers = []

    triggers << list.select { |el| el.is_a?(OtherExpression) }.map(&:generate)

    list.map! { |el| el.is_a?(OtherExpression) ? el.dc : el }

    triggers << list.map do |el|
      temp = DC.new(min: 0, max: el.cost)
      [
        el.countoff(constant*other, temp, -el),
        temp.countoff(el, -temp),
      ]
    end
    # _if( list.select { |el| el.is_a?(Switch) }.reduce(:&) )[
      # other << other + constant,
    #]
    triggers
  end

  def remove(other)
    list.select{ |el| el.is_a?(SumExpression) }.each { |el| el.remove(other) }
    list.delete(other)
    self.constant = 0 if list.empty?
    simplify
  end

  def simplify
    # self.constant *= list.select { |el| el.list.empty? }.map(&:constant).reduce(:*)
    # list.reject! { |el| el.list.empty? }
    list.sort!
  end

  def min
    minAndMax[:min]
  end

  def max
    minAndMax[:max]
  end

  def step
    list.select {|el| !el.is_a?(Switch) }.reduce(constant) { |acc, el| acc *= el.step }.abs
  end

  private

  def minAndMax
    [minval = constant, maxval = constant]
    list.each do |el|
      arr = [minval * el.min, minval * el.max, maxval * el.min, maxval * el.max]
      [minval = arr.min, maxval = arr.max]
    end
    {min: minval, max: maxval}
  end
end
