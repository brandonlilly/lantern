require_relative 'store'
require_relative 'actions'
require_relative 'conditions'
require_relative 'comparison'

class Switch
  include AndOr
  include StoreId
  @@store = Store.new

  attr_accessor :inverted

  def initialize(options = {})
    @inverted = options.fetch(:inverted, false)

    initialize_store(options, @@store)
  end

  def action(id, value)
    setSwitch(id, value)
  end

  def condition(id, state)
    switchIsState(id, state)
  end

  def <<(other)
    if other.is_a?(TrueClass) || other.is_a?(FalseClass) || other.is_a?(Symbol)
      return Assignment.new(self, other)
    end

    if other.is_a?(Switch)
      return [
        _if( other )[ self << true ],
        _if( !other )[ self << false ],
      ]
    end

    raise ArgumentError, "Expecting a Switch, Boolean, or Symbol, not: #{other}"
  end

  def set
    self << true
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

  def ==(other)
    if other.is_a?(TrueClass) || other.is_a?(FalseClass)
      return Comparison.new(self, :==, inverted ? !other : other)
    end

    if other.is_a?(Switch)
      return (self & other) | (!self & !other)
    end

    false
  end

  def !=(other)
    self == !other
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
      inverted: options.fetch(:inverted, inverted)
    )
  end

  def destroy
    clear
  end

  def to_s
    "Switch#{id}"
  end
end
