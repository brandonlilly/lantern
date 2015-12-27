require_relative 'store'
require_relative 'actions'
require_relative 'conditions'

class Switch
  include AndOr

  @@store = Store.new(size: 256)

  attr_accessor :id, :store, :inverted

  def initialize(options = {})
    @store =    options[:store] || @@store
    @id =       options[:id] || allocateId
    @inverted = options.fetch(:inverted, false)
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

    abort("Unrecognized parameter.")
  end

  def set
    self << true
  end

  def clear
    self << false
  end

  def toggle
    setSwitch(id, :toggle) # for now
  end

  # probably want to preserve original functionality somehow
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
      inverted: options.fetch(:inverted, inverted)
    )
  end

  def destroy
    self.class.finalize(store, id).call()
    ObjectSpace.undefine_finalizer(self)
    self.id = nil
  end

  def self.finalize(store, id)
    proc do
      store.remove(id)
    end
  end

  private

  def allocateId
    new_id = store.allocateId
    ObjectSpace.define_finalizer(self, self.class.finalize(store, new_id))
    new_id
  end
end
