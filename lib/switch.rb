require_relative 'store'
require_relative 'actions'
require_relative 'conditions'
require_relative 'assignment'

class Switch
  include AndOr
  include StoreId

  attr_accessor :inverted

  def initialize(options = {})
    @inverted = options.fetch(:inverted, false)

    initialize_store(options)
  end

  def <<(other)
    SwitchAssignment.new(self, other)
    SwitchAssignment.new(self, other).generate # TODO: remove this line later
  end

  def oldSet(other)
    if [TrueClass, FalseClass, String, Symbol].include?(other.class)
      return setSwitch(id, other)
    end

    if other.is_a?(Switch)
      return [
        _if( other )[ self << true ],
        _if( !other )[ self << false ],
      ]
    end
  end

  def setState(other)
    setSwitch(id, other)
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
end
