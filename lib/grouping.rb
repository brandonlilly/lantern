class Grouping
  attr_accessor :constant, :list

  def initialize(other)
    self.constant = 1
    self.list = [other]

    post_initialize(other)
  end

  def post_initialize(other)
    nil
  end

  def symbol
    raise NotImplementedError
  end

  def -(other)
    self + -other
  end

  def -@
    self * -1
  end

  def insert(other)
    list << other
    list.sort!
    self
  end

  def <=>(other)
    cost == other.cost ?
      (representation < other.representation ? -1 : 1) :
      (cost < other.cost ? -1 : 1)
  end

  def cost
    list.map(&:cost).reduce(symbol)
  end

  def representation
    "(" + list.map(&:representation).join(symbol) + ")"
  end

  def to_s
    "(" + [constant].concat(list).join(symbol) + ")"
  end

end

class Product < Grouping
  def symbol
    :*
  end

  def +(other)
    Sum.new(self) + other
  end

  def *(other)
    other = Product.new(other) if other.is_a?(Counter)
    if other.is_a?(Integer)
      return 0 if other == 0
      self.constant *= other
    elsif other.is_a?(Sum)
      insert(other)
    elsif other.is_a?(Product)
      other.list.each {|elem| insert(elem)}
    else
      raise ArgumentError, "Input needs to be an Integer, Counter, Sum, or Product"
    end
    self
  end
end

class Sum < Grouping
  def symbol
    :+
  end

  def +(other)
    other = Product.new(other) if other.is_a?(Counter)
    if other.is_a?(Integer)
      self.constant += other
    elsif other.is_a?(Product)
      insert(other)
    elsif other.is_a?(Sum)
      self.constant += other.constant
      other.list.each {|elem| insert(elem)}
    else
      raise ArgumentError, "Input needs to be an Integer, Counter, Sum, or Product"
    end
    list.length == 0 ? constant : self
  end

  def *(other)
    if other.is_a?(Integer)
      return 0 if other == 0
      self.constant *= other
      list.each {|elem| elem.constant *= other}
      return self
    end
    Product.new(self) * other
  end

  def insert(other)
    (0...list.length).each do |i|
      item = list[i]
      if item.representation == other.representation
        item.constant += other.constant
        list.delete_at(i) if item.constant == 0
        return self
      end
    end
    list << other
    list.sort!
    self
  end
end
