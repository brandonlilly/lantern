require_relative './lib/switch'
require_relative './lib/map'
require_relative './lib/dc'
require_relative './lib/resource'
require_relative './lib/sumexpression'
require_relative './lib/productexpression'
require_relative './lib/otherexpression'
require_relative './lib/assignment'
require_relative './lib/matrix'


lirin = Map.new


custom def squared(ret, value)
  actions = (0..7).map do |i|
    _if( value == i )[ ret << ret + (i ** 2) ]
  end
  ret.modifyBounds(min: 0, max: 7**2)
  actions
end



dc0 = DC.new(min: 0, max: 7)
dc1 = DC.new(min: 0, max: 7)
dc2 = DC.new(min: 0, max: 7)

lirin._if( test_cond('blue') ) [
  dc0 << squared(dc1+dc2)
]

puts lirin.render



# # setup
# xu << 1000 * sin(angle)
# yu << 1000 * cos(angle)
# dx << xorigin - xdest
# dy << yorigin - ydest
#
# # calculate distances
# para_dist << (xu * dx + yu * dy) / 1000
# perp_dist << (yu * dx - xu * dy) / 1000
#
# # find intersection
# _if ( (para_dist >= 0) & (perp_dist.abs < radius) ) [
#
#   offset << sqrt( radius ** 2 - perp_dist ** 2 ),
#
#   _if ( para_dist >= offset ) [
#     dist << para_dist - offset
#   ].else[
#     dist << para_dist + offset
#   ],
#
# ]
