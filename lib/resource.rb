require_relative 'actions'
require_relative 'conditions'

class Resource < Counter
  attr_accessor :player, :resource

  def post_initialize(options = {})
    self.player =   options[:player]
    self.resource = options[:resource]
  end

  def condition(qmod, amount)
    accumulate(player, qmod, amount, resource)
  end

  def action(vmod, amount)
    amount += 2**32 if amount < 0
    setResources(player, vmod, amount, resource)
  end

  def clone_defaults
    { player: player, resource: resource }
  end

  def representation
    "#{self}"
  end
  def to_s
    if resource == :ore
      "ore"
    elsif resource == :gas
      "gas"
    else
      "oreAndGas"
    end
  end
end
