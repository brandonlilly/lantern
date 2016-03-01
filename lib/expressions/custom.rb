require_relative '../counters/dc'
require_relative 'product'
require_relative 'term'

class CustomExpr
  include Term

  attr_accessor :actions, :ret

  def initialize(options)
    self.actions = options[:actions]
    self.ret = options[:ret]
  end

  def <<(other)
    raise NotImplementedError
  end

  def generate
    actions
  end

  def min
    ret.min
  end

  def max
    ret.max
  end

  def step
    ret.step
  end

  def to_cond
    raise ArgumentError
    # ret != 0
  end

  def cost
    ret.cost
  end

  def offset
    min
  end

  def representation
    "(" + args.map(&:representation).join(',') + "->" + ret.representation + ")"
  end

  def to_s
    "(" + args.map(&:representation).join(',') + "->" + ret.representation + ")"
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

    ret = DC.new
    actions << fn.call(ret, new_args)

    CustomExpr.new(actions: actions, ret: ret)
  end
end
