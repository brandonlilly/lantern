# Lantern
Lantern is a framework and DSL for compiling Starcraft triggers and successor to [Oreo Triggers](https://github.com/brandonlilly/oreo-triggers). It adds modularity, intuitive triggering, EUD, Switch and DC variable support, manages your resources and allows for custom built actions and conditions.

### Examples
General:
```ruby
timer = DC.new(0..60)
x =     DC.new(0..1023)
y =     DC.new(0..1023)
unit =  Unit.new(id: 5)

_always[
  timer << timer + 1,
  x << unit.x_pos,
  y << unit.y_pos,
]

_if( timer >= 60 )[
  timer << 0,

  dist << sqrt(x ** 2 + y ** 2),
  _if( dist > 100 )[
    display("Too far away!"),
    unit.move_home,
  ],
]
```

Native And, Or, and Not
```ruby
_if( (x > 10) & (y < 20) )[
  display("x is greater than 10 and y is less than 20")
]

_if( red | blue )[
  display("either red or blue (or both)!"),
]

_if( !red & !(blue & green) )[
  display("not red, and not blue or green")
]
```

Bounds inference:
```ruby
x = DC.new(0..50) # bounds: 0..50
y = DC.new(0..10) # bounds: 0..10

_if( some_condition )[
  x << 7 # bounds: 7..7
  y << x + 5 # bounds: 12..12 (done in 1 action)
]
.else[
  y << x + 5 # bounds: 5..55
]
```

Negative counter values:
```ruby
x = DC.new(-50..50)
y = DC.new(-50..50)

_if( x < -10 )[
  x << x + 1,
  y << -x + 20,
]
```

## Installation
`gem install bundler`  
`bundle install`  

## Testing
`bundle exec rspec`  
