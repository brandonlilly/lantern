require_relative './lib/switch'
require_relative './lib/map'
require_relative './lib/dc'
require_relative './lib/resource'
require_relative './lib/grouping'

# visitedTown = Switch.new
# injured = Switch.new

lirin = Map.new

x = DC.new(min: 0, max: 3)
# y = DC.new(min: 0, max: 7)
# z = DC.new(min: -2, max: 1)

lirin._if( test_cond("blue") )[
  x << 2*x,
]

puts lirin.render

# puts display("blue or green").render_xml
