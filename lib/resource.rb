require_relative 'actions'
require_relative 'conditions'

class Resource < Counter
  attr_accessor :player, :resource

  def post_initialize(options = {})
    self.player =   options[:player]
    self.resource = options[:resource]
  end

  def condition(qmod, amount)
    amount += 2**31
    accumulate(player, qmod, amount % 2**32, resource)
  end

  def action(vmod, amount)
    amount += 2**31 if vmod == :setto
    setResources(player, vmod, amount % 2**32, resource)
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
