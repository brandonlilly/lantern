# Triggers

The syntax of creating triggers mimics an if statement.

```ruby
_if( elapsed(10) )[
  display("It's been at least 10 seconds"),
]
```

## Or, And, Not

Conditions can be combined through the operators &, | and ! (and, or, not).

```ruby
# colors are all pseudo conditions
_if( red & orange & yellow )[
  display("Red, orange and yellow are all met."),
]

_if( blue | red )[
  display("Blue or red (or both!) are met."),
]

_if( !black )[
  display("Clearly its not black."),
]
```

And parentheses, of course
```ruby
_if( black & (red | blue) )[
  display("Definitely black and either red or blue.")
]
```

**Important**: Keep in mind that & and | have higher precedence than comparators (==, >=, < etc).
This means that you **must** wrap comparators conditions in parentheses if you intend to use them alongside other conditions.

```ruby
# bad
_if( dc < 10 | dc > 50 )[
  display("This won't parse correctly. You'll get an error.")
]

# good
_if( (dc < 10) | (dc > 50) )[
  display("Behaves as intended.")
]
```

### Nested triggers

```ruby
_if( red )[
  display("Red is set.")
  _if( blue )[
    display("And so is blue.")
  ]
]
```
