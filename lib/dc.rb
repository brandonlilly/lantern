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

  def condition(qmod, amount)
    amount += 2**31
    deaths(player, qmod, amount % 2**32, unit)
  end

  def action(vmod, amount)
    amount += 2**31 if vmod == :setto
    setDeaths(player, vmod, amount % 2**32, unit)
  end

  def representation
    "DC#{id}"
  end

  def to_s
    "DC#{id}"
  end
end
