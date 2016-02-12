require_relative 'dc'
require_relative 'productexpression'

class OtherExpression
  attr_accessor :actions, :function, :args, :dc, :triggers

  def initialize(actions, function, *args)
    self.actions = actions
    self.function = function
    self.args = *args
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
      triggers << actions
      triggers << (dc << 0) #TODO: can remove this
      triggers << (function.call(dc, *args))
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


def custom(fn_name)
  fn = method(fn_name)

  define_method(fn_name) do |*args|
    actions = []
    new_args = args.map do |arg|
      if arg.is_a?(Expression)
        temp = DC.new
        actions << (temp << arg)
        next temp
      end
      arg
    end

    OtherExpression.new(actions, fn, *new_args)
  end
end
