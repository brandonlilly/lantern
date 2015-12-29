class Resource
  attr_accessor :player, :resource

  def post_initialize(options = {})
    self.player =   options[:player]
    self.resource = options[:resource]
  end

  def condition(qmod, amount)
    accumulate(player, qmod, amount, resource)
  end

  def action(vmod, amount)
    setResources(player, vmod, amount, resource)
  end

  def clone_defaults
    { player: player, resource: resource }
  end
end
