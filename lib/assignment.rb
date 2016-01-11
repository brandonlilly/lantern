require_relative 'actions'
require_relative 'conditions'
require_relative 'grouping'

class Assignment

  attr_accessor :counter, :grouping

  def initialize(counter, grouping)
    self.counter = counter
    self.grouping = grouping
  end

  def virtual
    counter.modifyBounds(min: grouping.min, max: grouping.max, step: grouping.step)
    []
  end

  def generate
    actions = []
    if grouping.count(counter) == 0
      actions << counter.setTo(grouping.offset)
      actions << grouping.generate(counter)
    elsif grouping.contains_self?(counter)
      grouping.remove_self(counter)
      actions << counter.add(grouping.offset)
      actions << grouping.generate(counter)
    else
      temp = DC.new(min: min, max: max, step: step, implicit: true)
      actions << temp << other
      actions << counter.setTo(temp.min)
      actions << temp.countoff(self)
    end
    counter.modifyBounds(min: grouping.min, max: grouping.max, step: grouping.step)
    actions
  end
end
