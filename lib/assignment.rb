require_relative 'grouping'

class Assignment

  attr_accessor :counter, :grouping

  def initialize(counter, grouping)
    raise ArgumentError if !counter.is_a?(Counter)
    grouping = Product.new(grouping) if !grouping.is_a?(Sum) && !grouping.is_a?(Product)
    grouping = Sum.new(grouping) if !grouping.is_a?(Sum)
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
      grouping.remove(counter)
      actions << counter.add(grouping.offset)
      actions << grouping.generate(counter)
    else
      temp = DC.new
      actions << temp << other
      actions << counter << temp
    end
    counter.modifyBounds(min: grouping.min, max: grouping.max, step: grouping.step)
    actions
  end
end
