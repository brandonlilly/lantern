require_relative 'actions'
require_relative 'conditions'

class Counter
  include AndOr

  attr_accessor :min, :max, :step

  def initialize(options = {})
    self.max =  options[:max]
    self.min =  options[:min] || 0
    self.step = options[:step] || 1

    post_initialize(options)
  end

  def post_initialize(options)
    nil
  end

  def implicit
    false
  end

  def action(vmod, amount)
    raise NotImplementedError
  end

  def condition(qmod, amount)
    raise NotImplementedError
  end

  def <<(other)
    return action(:setto, other) if other.is_a?(Integer)
    other = Product.new(other) if other.is_a?(Counter)
    other = Sum.new(other) if other.is_a?(Product)
    if other.contains_none?(self)
      [
        action(:setto, other.min),
        other.evaluateInto(self),
      ]
    elsif other.contains_self?(self)
      other.remove_self(self)
      return [] if other.list.length == 0 && other.constant == 0
      [
        action(:add, other.min),
        other.evaluateInto(self),
      ]
    else
      temp = DC.new(min: min, max: max, step: step, implicit: true)
      [
        temp << other,
        self << temp,
      ]
    end
  end

  def +(other)
    Product.new(self) + other
  end

  def -(other)
    Product.new(self) - other
  end

  def -@
    Product.new(self) * -1
  end

  def *(other)
    Product.new(self) * other
  end

  def /(other)
    raise NotImplementedError
  end

  def %(other)
    raise NotImplementedError
  end

  def **(other)
    raise NotImplementedError
  end

  def ==(other)
    test_cond("#{self} == #{other}") # todo
  end

  def >(other)
    test_cond("#{self} > #{other}") # todo
  end

  def <(other)
    test_cond("#{self} < #{other}") # todo
  end

  def >=(other)
    test_cond("#{self} >= #{other}") # todo
  end

  def <=(other)
    test_cond("#{self} <= #{other}") # todo
  end

  # countoff
  def countoff(*args)
    # prep
    coef = args.last.is_a?(Integer) ? args.last : 1
    objs = args.last.is_a?(Integer) ? args[0..-2] : args

    if objs.empty? || !objs.all? { |obj| obj.is_a?(Counter) }
      raise ArgumentError, "Countoff requires Counter(s) as input (DC, Resource, Score, etc., optional multiplier on end)"
    end

    actions = []

    # allocate temp DC
    if !implicit
      temp = DC.new(
        min: 0,
        max: (max - min) / step,
        implicit: true
      )
    end

    # preliminary
    # actions << objs.map { |obj| obj.action(:add, max - min) } if step > 0 && max != 0
    actions << temp.action(:setto, 0) if !implicit
    actions << action(:add, -min) if min != 0

    # countoff
    power = nearestPower((max - min) / step)
    each_power(power) do |k|
      actions << _if( self >= k * step )[
        objs.map { |obj| obj.action(:add, coef * k * step) },

        !implicit ?
          [ action(:subtract, k * step), temp.action(:add, k) ] :
          [ action(:subtract, k * step) ],
      ]
    end

    # count back
    actions << temp.countoff(self) if !implicit

    # post
    actions << action(:add, min) if !implicit && min != 0
    actions << action(:setto, 0) if implicit

    freeImplicitObjs(self) if implicit

    actions
  end

  def cost
    (max - min) / step
  end

  protected

  def clone(options = {})
    defaults = { max: max, min: min, step: step }
    self.class.new(
      defaults
        .merge(clone_defaults)
        .merge(options)
    )
  end

  def clone_defaults
    {}
  end

  def freeImplicitObjs(*objs)
    objs.each do |obj|
      obj.destroy if obj.is_a?(DC) && obj.implicit
    end
  end

  def nearestPower(num)
    i = 1
    i <<= 1 while 2*i <= num
    i
  end

  def each_power(power, &block)
    k = power
    while k >= 1
      block.call(k)
      k = k / 2
    end
  end

  def errorCheckObj(*objs)
    unless objs.all? { |obj| !obj.is_a?(DC) || obj.bounded? }
      raise ArgumentError, <<-MSG
      DC must have defined bounds before it is used!
      Consider defining bounds when it is declared,
      ie. myDC = DC.new(min: -1, max: 5)"
      MSG
    end
  end

  def bounded?
    min && max
  end

end
