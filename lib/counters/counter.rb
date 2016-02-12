require_relative '../assignment'
require_relative '../expressions/term'

class Counter
  include AndOr
  include Term

  attr_accessor :min, :max, :step

  def initialize(options = {})
    self.max =  options[:max]
    self.min =  options[:min]  || 0
    self.step = options[:step] || 1

    post_initialize(options)
  end

  def modifyBounds(options = {})
    self.max =  options[:max]  || max
    self.min =  options[:min]  || min
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
    amount == 0 ? [] : action(:add, adjust(amount))
  end

  def subtract(amount)
    amount == 0 ? [] : action(:subtract, adjust(amount))
  end

  def setTo(amount)
    action(:setto, adjust(amount, SHIFTED_ZERO))
  end

  def exactly(amount)
    condition(:exactly, adjust(amount, SHIFTED_ZERO))
  end

  def atMost(amount)
    condition(:atmost, adjust(amount, SHIFTED_ZERO))
  end

  def atLeast(amount)
    condition(:atleast, adjust(amount, SHIFTED_ZERO))
  end

  def adjust(amount, offset = 0)
    (amount + offset) % MAX_INT
  end

  SHIFTED_ZERO = 2**31
  MAX_INT = 2**32

  def <<(other)
    CounterAssignment.new(self, other)
    CounterAssignment.new(self, other).generate # TODO: remove this line
  end

  def to_cond
    raise ArgumentError
    # self != 0
  end

  def cost
    (max - min) / step
  end

  def offset
    min
  end

  def count(other)
    representation == other.representation ? 1 : 0
  end

  def unique
    self
  end

  def countoff(*others)
    others = formatGroup(others)
    each_power(cost).map do |k|
      _if( self >= k * step + min )[
        # TODO: implement el.list.first << el.list.first + k * step * el.constant ?
        others.map { |el| el.list.first.add(k * step * el.constant) }
      ]
    end
  end

  protected

  def formatGroup(obj)
    obj = [obj] unless obj.is_a?(Array)
    raise ArgumentError if obj.any? { |el| !el.is_a?(ProductExpression) && !el.is_a?(Counter)}
    obj.map { |el| el.is_a?(Counter) ? 1 * el : el }
  end

  def nearestPower(num)
    num <= 0 ? 0 : 2 ** Math.log(num,2).floor
  end

  def each_power(num, &block)
    return to_enum(:each_power, num) unless block_given?
    k = nearestPower(num)
    while k >= 1
      block.call(k)
      k = k / 2
    end
  end

  def bounded?
    min && max
  end

end
