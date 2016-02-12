require_relative './lib/switch'
require_relative './lib/map'
require_relative './lib/counters/dc'
require_relative './lib/counters/resource'
require_relative './lib/expressions/expression'

# visitedTown = Switch.new
# injured = Switch.new

lirin = Map.new

def red; test_cond("red"); end;
def blue; test_cond("blue"); end;
def black; test_cond("black"); end;

x = DC.new(min: 0, max: 7)
y = DC.new(min: 0, max: 7)

lirin._if( blue )[
  x << y,
]

puts lirin.render
