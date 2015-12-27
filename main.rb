require_relative './lib/switch'
require_relative './lib/map'
require_relative './lib/dc'

visitedTown = Switch.new
injured = Switch.new

lirin = Map.new

lirin._if( test_cond("blue") | test_cond("green") | test_cond("black") )[
  display("blue or green or maybe even black"),
]

puts lirin.run
