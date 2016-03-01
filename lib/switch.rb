require_relative 'store'
require_relative 'actions'
require_relative 'conditions'
require_relative 'expressions/term'
require_relative 'assignment'
require_relative 'wrapper'

class Switch
  include AndOr
  include StoreId
  include Term
  @@store = Store.new

  attr_accessor :inverted, :name, :switch_id

  def initialize(options = {})
    self.switch_id =  options[:switch_id]
    self.name =       options[:name] || 'Switch'
    self.inverted =   options.fetch(:inverted, false)

    initialize_store(options, @@store)
  end

  def action(state)
    setSwitch(switch_id, state)
  end

  def condition(state)
    switchIsState(switch_id, state)
  end

  def <<(other)
    if [TrueClass, FalseClass, String, Symbol].include?(other.class)
      return wrap(:<<, other)
    end

    # SwitchAssignment.new(self, other)
    SwitchAssignment.new(self, other).generate # TODO: remove this line later
  end

  def ==(other)
    if other.is_a?(TrueClass) || other.is_a?(FalseClass)
      return wrap(:==, inverted ? !other : other)
    end

    if other.is_a?(Switch)
      return (self & other) | (!self & !other)
    end

    false
  end

  def !=(other)
    self == !other
  end

  def set(other)
    self << other
  end

  def clear
    self << false
  end

  def toggle
    self << :toggle
  end

  def randomize
    self << :randomize
  end

  def set?
    self == true
  end

  def clear?
    self == false
  end

  def to_cond
    set?
  end

  def !
    clone(inverted: !inverted)
  end

  def clone(options = {})
    self.class.new(
      store:    options[:store] || store,
      id:       options[:id] || id,
      name:       options[:name] || name,
      switch_id:  options[:switch_id] || switch_id,
      inverted: options.fetch(:inverted, inverted)
    )
  end

  def count(other)
    representation == other.representation ? 1 : 0
  end

  def unique
    self
  end

  def cost
    0
  end

  def offset
    0
  end

  def min
    0
  end

  def max
    1
  end

  def >=(other)
    raise InvalidOperationError
  end

  def <=(other)
    raise InvalidOperationError
  end

  def >(other)
    raise InvalidOperationError
  end

  def <(other)
    raise InvalidOperationError
  end

  def wrap(operator, state)
    SwitchWrapper.new(self, operator, state)
  end

  def representation
    "Switch#{id}"
  end

  def to_s
    "#{name}##{id}"
  end
end

class InvalidOperationError; end
