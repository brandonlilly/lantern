require_relative 'grouping'
require_relative 'counter'
require_relative 'switch'

class Assignment
  attr_accessor :object, :grouping

  def initialize(object, grouping)
    object = prepare_object(object)
    grouping = prepare_grouping(grouping)

    self.object = object
    self.grouping = grouping
  end

  def prepare_object(object)
    raise NotImplementedError
  end

  def prepare_grouping(grouping)
    raise NotImplementedError
  end

  def virtual
    raise NotImplementedError
  end

  def generate
    raise NotImplementedError
  end

end


class CounterAssignment < Assignment

  def prepare_object(object)
    raise ArgumentError if !object.is_a?(Counter)
    object
  end

  def prepare_grouping(grouping)
    grouping = Product.new(grouping) if !grouping.is_a?(Sum) && !grouping.is_a?(Product)
    grouping = Sum.new(grouping) if !grouping.is_a?(Sum)
    grouping
  end

  def virtual
    object.modifyBounds(min: grouping.min, max: grouping.max, step: grouping.step)
    []
  end

  def generate
    actions = []
    if grouping.count(object) == 0
      actions << object.setTo(grouping.offset)
      actions << grouping.generate(object)
    elsif grouping.contains_self?(object)
      grouping.remove(object)
      actions << object.add(grouping.offset)
      actions << grouping.generate(object)
    else
      temp = DC.new
      actions << temp << other
      actions << object << temp
    end
    object.modifyBounds(min: grouping.min, max: grouping.max, step: grouping.step)
    actions
  end

end


class SwitchAssignment < Assignment

  def prepare_object(object)
    raise ArgumentError if !object.is_a?(Switch)
    object
  end

  def prepare_grouping(grouping)
    grouping
  end

  def &(other)
    grouping &= other
    self
  end

  def |(other)
    grouping |= other
    self
  end

  def virtual
    []
  end

  def generate
    return object.setState(grouping) if grouping.is_a?(TrueClass) || grouping.is_a?(FalseClass)
    [
      object << false,
      _if( grouping )[
        object << true
      ],
    ]
  end

end
