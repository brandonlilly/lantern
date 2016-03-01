require_relative './lib/switch'
require_relative './lib/map'
require_relative './lib/counters/dc'

lirin = Map.new

red = test_cond("red")
blue = test_cond("blue")
black = test_cond("black")

x = DC.new(min: 0, max: 7, name: 'x')
y = DC.new(min: 0, max: 7, name: 'y')

lirin.eval do

  _if( blue )[
    x << 3,
    y << x,
  ]

  _if( red )[

  ]

end

puts lirin.render
