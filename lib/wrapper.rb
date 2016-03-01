class SwitchWrapper
  attr_accessor :var, :operator, :value

  def initialize(var, operator, value)
    self.var = var
    self.value = value
    self.operator = operator
  end

  def generate
    case operator
    when :<<
      var.action(value)
    when :==
      var.condition(value)
    else
      raise "Unknown operator #{operator}."
    end
  end

  def to_cond
    self
  end

  def type
    'Switch'
  end

  def type?(cond_type)
    cond_type == type
  end

  def to_s
    "#{self.class}{ #{var} #{operator} #{value} }"
  end

  def render
    to_s
  end
end

class DCWrapper
  attr_accessor :var, :modifier, :value

  def initialize(var, modifier, value)
    self.var = var
    self.value = value
    self.modifier = modifier
  end

  def generate
    case modifier
    when :setto, :add, :subtract
      var.action(modifier, value)
    when :exactly, :atleast, :atmost
      var.condition(modifier, value)
    else
      raise "Unknown modifer #{modifer}."
    end
  end

  def to_cond
    self
  end

  def type
    'Switch'
  end

  def type?(cond_type)
    cond_type == type
  end

  def to_s
    "#{self.class}{ #{var} #{modifier} #{value} }"
  end

  def render
    to_s
  end
end
