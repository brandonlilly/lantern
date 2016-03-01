require_relative 'lib/switch'
require_relative 'lib/map'
require_relative 'lib/counters/dc'
require_relative 'lib/conditions'
require_relative 'lib/actions'

red = test_cond("red")
blue = test_cond("blue")
black = test_cond("black")

map = Map.new

x = DC.new(min: 0, max: 7, name: 'x')
y = DC.new(min: 0, max: 7, name: 'y')

map.instance_eval do

  _if( blue )[
    x << y,
  ]

end

puts map.render
