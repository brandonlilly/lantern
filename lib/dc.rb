require_relative 'store'
require_relative 'actions'
require_relative 'conditions'
require_relative 'counter'
require_relative 'fixnum'

class DC < Counter
  include StoreId

  def post_initialize(options = {})
    initialize_store(options)
  end

  def player
    "Player 1"
  end

  def unit
    # "Terran Marine"
    "#{self}"
  end

  def action(vmod, amount)
    amount += 2**32 if amount < 0
    setDeaths(player, vmod, amount, unit)
  end

  def condition(qmod, amount)
    deaths(player, qmod, amount, unit)
  end

  def representation
    "DC#{id}"
  end
  def to_s
    "DC#{id}"
  end

  private

  def clone_defaults
    { id: id, implicit: implicit, store: store }
  end
end
