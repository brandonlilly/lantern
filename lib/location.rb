class Location
  attr_accessor :name

  def initialize(options = {})
    self.name = options[:name] || raise ArgumentError
  end

  def acquire(*locations)
    locations.map do |location|
      moveLocation(location, "Neutral", "Map Revealer", self)
    end
  end

  def centerOn(player, unit, location)
    moveLocation(self, player, unit, location)
  end

  def centerView
    centerView(self)
  end

  def ping
    ping(self)
  end

  def explode(owner = "Player 8")
    unit = "Terran Wraith"
    [ 
      createUnit(owner, unit, 1, self),
      killUnit(owner, unit)
    ]
  end
end
