require_relative 'counter'
require_relative '../store'
require_relative '../actions'
require_relative '../conditions'
require_relative '../fixnum'
require_relative '../wrapper'

class DC < Counter
  include StoreId
  @@store = Store.new

  def post_initialize(options = {})
    initialize_store(options, @@store)
  end

  def default_name
    "DC"
  end

  def player
    "Player 1"
  end

  def unit
    "Terran Marine"
  end

  def condition(qmod, amount)
    deaths(player, qmod, amount, unit)
  end

  def action(vmod, amount)
    setDeaths(player, vmod, amount, unit)
  end

  def representation
    "DC#{id}"
  end

  def to_s
    "#{name}##{id}"
  end
end
