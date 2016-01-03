# Custom Functions

## Custom Actions

Creating an action is as simple as returning an action, or an array of actions.

Suppose you always want some dialogue to always be displayed with the same formatting. You could create an action for it:
```ruby
def dialogue(name, text)
  [
    display("\\x004\\x013[#{name}]"),
    display("\\x01E\\x013#{text}"),
  ]
end

# usage
_if( some_condition )[
  dialogue("Guard", "Who goes there?")
]
```
This way we can easily update the format for all dialogue in our map when we want to make changes.

## Custom Conditions

Creating a condition can be as simple as returning a single condition or condition expression. For instance, suppose you wanted to create a xor condition for when one of two switches is set but not both. You could implement it like this:

```ruby
def xor(switch1, switch2)
  (switch1 & !switch2) | (!switch1 & switch2)
end

# alternatively
def xor(switch1, switch2)
  (switch1 | switch2) & !(switch1 & switch2)
end
```
And then use it like so:
```ruby
_if( xor(red, blue) )[
  display('Either red or blue is set, but not both.')
]
```


### conditional
`conditional` is a function used to create custom conditions. It expects a block that returns an array of actions. The block is passed a switch which you are expected to set based on when the condition is met.

Suppose you wanted to implement the xor condition using `conditional`.

```ruby
def xor(switch1, switch2)
  conditional do |cond|
    [
      _if(switch1)[ cond.toggle ],
      _if(switch2)[ cond.toggle ],
    ]
  end
end
```
If neither of the switches are set, our condition switch (cond) will never be toggled on. If both switches are set, the condition switch will be toggled twice (on then off), leaving it off. If only one of our switches is set, cond is properly toggled once, leaving it set. This is the desired logic for our condition.
