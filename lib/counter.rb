require_relative 'actions'
require_relative 'conditions'
require_relative 'grouping'

class Counter
  include AndOr

  attr_accessor :min, :max, :step

  def initialize(options = {})
    self.max =  options[:max]
    self.min =  options[:min] || 0
    self.step = options[:step] || 1

    post_initialize(options)
  end

  def modifyBounds(options = {})
    self.max =  options[:max] || max
    self.min =  options[:min] || min
    self.step = options[:step] || step
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

  def representation
    raise NotImplementedError
  end

  def add(amount)
    action(:add, amount)
  end

  def subtract(amount)
    action(:subtract, amount)
  end

  def setTo(amount)
    adjusted = (amount + 2**31) % 2**32
    action(:setto, adjusted)
  end

  def <<(other)
    if other.is_a?(Integer)
      modifyBounds(min: other, max: other, step: 1)
      return action(:setto, other)
    end
    other = Product.new(other) if other.is_a?(Counter)
    other = Sum.new(other) if other.is_a?(Product)
    if other.contains_none?(self)
      modifyBounds(min: other.min, max: other.max, step: other.step)
      [
        action(:setto, other.offset),
        other.evaluateInto(self),
      ]
    elsif other.contains_self?(self)
      other.remove_self(self)
      return [] if other.list.length == 0 && other.constant == 0
      [
        action(:add, other.offset),
        other.evaluateInto(self),
      ]
    else
      temp = DC.new(min: min, max: max, step: step, implicit: true)
      [
        temp << other,
        action(:setto, temp.min),
        temp.countoff(self),
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
    return never() if min > other.max || max < other.min
    return condition(:exactly, other) if other.is_a?(Integer)
    return other == self if lower_cost?(other)
    compare(other, :==)
  end

  def !=(other)
    return [] if min > other.max || max < other.min
    return !(other == self) if lower_cost?(other)
    !(self == other)
  end

  def >(other)
    return [] if min > other.max
    return never() if max <= other.min
    return condition(:atleast, other+1) if other.is_a?(Integer)
    return other <= self if lower_cost?(other)
    compare(other, :>)
  end

  def <(other)
    return [] if min < other.max
    return never() if max >= other.min
    return condition(:atmost, other-1) if other.is_a?(Integer)
    return other >= self if lower_cost?(other)
    compare(other, :<)
  end

  def >=(other)
    return [] if min >= other.max
    return never() if max < other.min
    return condition(:atleast, other) if other.is_a?(Integer)
    return other < self if lower_cost?(other)
    compare(other, :>=)
  end

  def <=(other)
    return [] if min <= other.max
    return never() if max > other.min
    return condition(:atmost, other) if other.is_a?(Integer)
    return other > self if lower_cost?(other)
    compare(other, :<=)
  end

  def lower_cost?(other)
    [cost, (max - other.min + step - 1) / step].min > [other.cost, (other.max - min + other.step - 1) / other.step].min
  end

  def compare(other, symbol)
    cost <= (max { |a, b|  } - other.min + step - 1) / step ?
      [range = cost, minval = min] :
      [range = (max - other.min + step - 1) / step, minval = other.min - (other.min - max) % step]
    power = nearestPower(range)

   conditional do |cond|
     temp = DC.new(min: 0, max: range, implicit: true)
     actions = []

     actions << temp.action(:setto, 0)
     each_power(power) do |k|
       actions << _if( self >= k * step + minval )[
         other << other - k * step,
         self << self - k * step,
         temp << temp + k,
       ]
     end
     actions << _if( other.send(symbol, minval) ) [ cond << true ]
     each_power(power) do |k| #TODO replace with countoff?
       actions << _if( temp >= k )[
         other << other + k * step,
         self << self + k * step,
         temp << temp - k,
       ]
     end
     actions << temp.action(:setto, 2**31)

     freeImplicitObjs(temp)

     actions
   end
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

    # countoff
    power = nearestPower((max - min) / step)
    each_power(power) do |k|
      actions << _if( self >= k * step + min )[
        objs.map { |obj| obj << obj + coef * k * step },

        !implicit ?
          [ self << self - k * step, temp << temp + k ] :
          [ self << self - k * step ],
      ]
    end

    # count back
    # actions << temp.countoff(self, self.step) if !implicit
    actions << temp.countoff(self, step) if !implicit

    # post
    actions << action(:setto, 2**31) if implicit
    freeImplicitObjs(self) if implicit

    actions
  end

  def cost
    (max - min) / step
  end

  protected

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
    return to_enum(:each_power, power) unless block_given?

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
