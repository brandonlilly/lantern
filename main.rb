require_relative './lib/switch'
require_relative './lib/map'
require_relative './lib/dc'
require_relative './lib/resource'
require_relative './lib/grouping'
require_relative './lib/assignment'
require_relative './lib/comparison'

visitedTown = Switch.new
injured = Switch.new

lirin = Map.new

x = DC.new(min: 0, max: 7)
y = DC.new(min: 0, max: 7)

lirin._if( test_cond("blue") )[
  display("tits"),
  x << y,
]

puts lirin.generate.flatten.map(&:render)
