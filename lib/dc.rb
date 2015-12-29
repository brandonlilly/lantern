require_relative 'store'
require_relative 'actions'
require_relative 'conditions'
require_relative 'counter'

class DC < Counter
  @@store = Store.new(size: 256)

  attr_accessor :id, :implicit, :root, :store

  def post_initialize(options = {})
    self.store =    options[:store] || @@store
    self.id =       options[:id] || allocateId
    self.root =     options[:root] || self
    self.implicit = options.fetch(:implicit, false)
  end

  def temp(options = {})
    self.class.new(options.merge(
      implicit: true
    ))
  end

  def player
    "Player 1"
  end

  def unit
    "Terran Marine"
  end

  def action(vmod, amount)
    setDeaths(player, vmod, amount, unit)
  end

  def condition(qmod, amount)
    deaths(player, qmod, amount, unit)
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

  def to_s
    "DC#{id}"
  end

  private

  def allocateId
    new_id = store.allocateId
    ObjectSpace.define_finalizer(self, self.class.finalize(store, new_id))
    new_id
  end

  def clone(options = {})
    self.class.new(
      max:  options[:max]  || max,
      min:  options[:min]  || min,
      id:   options[:id]   || id,
      step: options[:step] || step,
      implicit: true,
      root: self,
    )
  end
end
