require_relative './lib/switch'
require_relative './lib/map'
require_relative './lib/dc'

visitedTown = Switch.new
injured = Switch.new

lirin = Map.new

dc = DC.new(min: 0, max: 100)

lirin._if( test_cond("blue") )[
  display("blue or green or maybe even black"),
  dc << 7,
  dc << dc - 3,
]

puts lirin.render

# puts display("blue or green").render_xml
