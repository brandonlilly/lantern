class Comparison
  attr_accessor :left, :operator, :right

  def initialize(left, operator, right)
    self.left = left
    self.operator = operator
    self.right = right
  end

  def render
    "#{left} #{operator} #{right}"
  end

  def run
    case operator
    when :==
      left.eq(right)
    when :>=
      left.gte(right)
    when :>
      left.gt(right)
    when :<
      left.lt(right)
    when :<=
      left.lte(right)
    else
      raise "Unrecognized operator: #{operator}."
    end
  end
end

class Assignment
  attr_accessor :left, :right

  def initialize(left, right)
    self.left = left
    self.right = right
  end

  def render
    "#{left} << #{right}"
  end

  def run
    left.setTo(right)
  end
end
