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

  def to_s
    "#{self.class}{ #{var} #{operator} #{value} }"
  end

  def render
    to_s
  end
end
