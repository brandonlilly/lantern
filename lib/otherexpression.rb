require_relative 'dc'
require_relative 'productexpression'

class OtherExpression
  attr_accessor :args, :action_block, :dc, :triggers

  def initialize(args, action_block)
    self.args = args
    self.action_block = action_block
    self.dc = DC.new
    self.triggers = []
  end

  def <<(other)
    raise NotImplementedError
  end

  def +(other)
    ProductExpression.new(self) + other
  end

  def -(other)
    ProductExpression.new(self) - other
  end

  def -@
    ProductExpression.new(self) * -1
  end

  def *(other)
    ProductExpression.new(self) * other
  end

  def /(other)
    raise NotImplementedError
  end

  def %(other)
    raise NotImplementedError
  end

  def **(other)
    raise NotImplementedError if !other.is_a?(Integer)
    (1..other).reduce(1) { |acc, el| acc * self }
  end

  def ==(other)
    ProductExpression.new(self) == other
  end

  def >=(other)
    ProductExpression.new(self) >= other
  end

  def <=(other)
    ProductExpression.new(self) <= other
  end

  def !=(other)
    !(self == other)
  end

  def >(other)
    self >= other + 1
  end

  def <(other)
    self <= other - 1
  end

  def <=>(other)
    representation <=> other.representation
  end

  def process
    if triggers.empty?
      triggers << dc << 0
      triggers << action_block.call(dc)
    end
  end

  def generate
    triggers
  end

  def min
    process
    dc.min
  end

  def max
    process
    dc.max
  end

  def step
    process
    dc.step
  end

  def to_cond
    raise ArgumentError
    # dc != 0
  end

  def cost
    process
    dc.cost
  end

  def offset
    min
  end

  def count(other)
    args.reduce(0) { |acc, el| acc += el.count(other) }
  end

  def unique
    args.map(&:unique).flatten.uniq.sort
  end

  def representation
    "(" + args.map(&:representation).join(',') + "->" + dc.representation + ")"
  end

  def to_s
    "(" + args.map(&:representation).join(',') + "->" + dc.representation + ")"
  end
end

def action(*args, &action_block)
  OtherExpression.new(args, action_block)
end
