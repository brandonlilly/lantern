require_relative 'store'
require_relative 'actions'
require_relative 'conditions'

class Switch
  include AndOr
  include StoreId

  attr_accessor :inverted

  def initialize(options = {})
    @inverted = options.fetch(:inverted, false)

    initialize_store(options)
  end

  def <<(other)
    if other.is_a?(TrueClass) || other.is_a?(FalseClass)
      return setSwitch(id, other)
    end

    if other.is_a?(Switch)
      return [
        _if( other )[ self << true ],
        _if( !other )[ self << false ],
      ]
    end

    raise ArgumentError, "Expecting boolean or Switch: #{other}"
  end

  def set
    self << true
  end

  def clear
    self << false
  end

  def toggle
    setSwitch(id, :toggle)
  end

  def ==(other)
    if other.is_a?(TrueClass) || other.is_a?(FalseClass)
      return switchIsState(id, inverted ? !other : other)
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
      implicit: options.fetch(:implicit, implicit),
      inverted: options.fetch(:inverted, inverted)
    )
  end
end
