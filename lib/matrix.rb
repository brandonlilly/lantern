require_relative 'counter'

class Matrix
  attr_accessor :dimensions, :data

  def initialize(other)
    if other.is_a?(Matrix)
      self.dimensions = other.dimensions
      self.data = other.data
    elsif !other.is_a?(Array)
      self.dimensions = [1]
      self.data = [other]
    else # Array
      self.dimensions = []
      unpackInput(other)
      checkInput(other, dimensions)
      self.data = other.flatten
    end
  end

  def <<(other)
    doEachCorresponding(other, :<<)
  end

  def +(other)
    doEachCorresponding(other, :+)
  end

  def -(other)
    doEachCorresponding(other, :-)
  end

  def multEach(other)
    doEachCorresponding(other, :*)
  end

  def divEach(other)
    doEachCorresponding(other, :/)
  end

  def modEach(other)
    doEachCorresponding(other, :%)
  end

  def expEach(other)
    doEachCorresponding(other, :**)
  end

  def -@
    data.map { |el| -el }
  end

  def *(other)
    return doEachCorresponding(other, :*) if other.is_a?(Fixnum)
    other = Matrix.new(other)
    raise ArgumentError if dimensions != other.dimensions
    (0...data.length).map { |idx| data[idx] - other.data[idx] }
  end

  def /(other)
    return doEachCorresponding(other, :/) if other.is_a?(Fixnum)
    raise NotImplementedError
  end

  def %(other)
    return doEachCorresponding(other, :%) if other.is_a?(Fixnum)
    raise NotImplementedError
  end

  def **(other)
    raise NotImplementedError
  end

  def [](index = nil)
    index = 0...dimensions[selectedDim] if index == nil
    self.selectedDim += 1
    "ACCESS INDEX #{index}"
  end

  def dot(other)
    doEachCorresponding(other, :*).sum
  end

  def sum #TODO: sum along specified dimension
    data.reduce(:+)
  end

  def representation
    to_s
  end

  def to_s
    formatAsString
  end

  private

  attr_accessor :selectedDim

  def unpackInput(other)
    self.dimensions << other.length
    unpackInput(other.first) if other.first.is_a?(Array)
  end

  def checkInput(other, dims)
    raise ArgumentError if other.length != dims.first
    other.each { |el| checkInput(el, dims[1..-1]) } if dims.length > 1
  end

  def doEachCorresponding(other, symbol)
    return data.map { |el| el.send(symbol, other) } if other.is_a?(Fixnum)
    other = Matrix.new(other)
    raise ArgumentError if dimensions != other.dimensions
    Matrix.new(formatAsArray((0...data.length).map { |idx| data[idx].send(symbol, other.data[idx]) }))
  end

  def formatAsArray(list=data, dims=dimensions)
    if dims.length > 1
      list.each_slice(dims.first).to_a.map { |el| formatAsArray(el, dims[1..-1]) }
    else
      list
    end
  end

  def formatAsString(list=formatAsArray)
    return list.to_s if !list.is_a?(Array)
    "[" + list.map { |el| formatAsString(el) }.join(',') + "]"
  end
end
