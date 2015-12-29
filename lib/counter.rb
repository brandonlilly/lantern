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

  def action(vmod, amount)
    raise NotImplementedError
  end

  def condition(qmod, amount)
    raise NotImplementedError
  end

  def <<(other)
    if other.is_a?(Integer)
      self.min = other
      self.max = other
      self.step = 1
      return setToAction(other)
    end

    if other.is_a?(Counter)
      errorCheckObj(other)
      self.min = other.min
      self.max = other.max
      self.step = other.step.abs
      return test_action("#{self} << #{other}")
    end

    raise ArgumentError, "Need Integer or Counter"
  end

  def +(other)
    if other.is_a?(Integer)
      return clone(max: max + other, min: min + other)
    end

    if other.is_a?(Counter)
      return test_action("#{self} + #{other}")
    end

    raise ArgumentError, "Need Integer or Counter"
  end

  def *(other)
    if other.is_a?(Integer)
      bounds = [max * other, min * other]
      return clone(max: bounds.max, min: bounds.min, step: step * other)
    end

    if other.is_a?(Counter)
      bounds = [min * other.min, min * other.max, max * other.min, max * other.max]
      dc = DC.temp(max: bounds.max, min: bounds.min, step: step * other.step)
      return dc # todo
    end

    raise ArgumentError, "Need Integer or Counter"
  end

  def /(other)
    errorCheckObj(self, other)

    if other.is_a?(Integer)
      return clone(
        max:  (max + other - 1) / other,
        min:  (min + other - 1) / other,
        step: (step + other - 1) / other
      )
    end

    if other.is_a?(DC) && root === other.root
      # todo: try to combine dc without using triggers
    end

    if other.is_a?(Counter)
      # todo: do this entire section
    end

    raise ArgumentError, "Need Integer or Counter"
  end

  def -(other)
    self + -other
  end

  def -@
    self * (-1)
  end

  # countoff
  def countoff(*args)
    # prep
    coef = args.last.is_a?(Integer) ? args.last : 1
    objs = args.last.is_a?(Integer) ? args[0..-2] : args

    if objs.empty? || !objs.all? { |obj| obj.is_a?(DC) }
      raise ArgumentError, "Countoff requires DC(s) as input (optional multiplier on end)"
    end

    actions = []

    # allocate temp DC
    if !root.implicit
      temp = self.class.new(
        min: 0,
        max: (root.max - root.min) / root.step,
        implicit: true
      )
    end

    # preliminary
    actions << objs.map { |obj| obj.add(max - min) } if step > 0 && max != 0
    actions << temp.set(0) if !root.implicit
    actions << root.subtract(root.min) if root.min != 0

    # countoff
    power = nearestPower((root.max - root.min) / root.step)
    each_power(power) do |k|
      actions << _if( root >= k * root.step )[
        objs.map { |obj| obj.add(coef * k * step) },

        !root.implicit ?
          [ root.subtract(k * root * step), temp.add(temp + k) ] :
          [ root.subtract(k * root.step) ],
      ]
    end

    # count back
    actions << temp.countoff(root) if !root.implicit

    # post
    actions << root += root.min if !root.implicit && min != 0
    actions << root << 0 if root.implicit

    freeImplicitObjs(self) if root.implicit

    actions
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
      obj.destroy if obj.is_a?(DC) && obj.root.implicit
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
