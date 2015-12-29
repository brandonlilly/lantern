require_relative 'store'
require_relative 'actions'
require_relative 'conditions'

class DC
  include AndOr

  # static
  @@store = Store.new(size: 256)

  # getters
  attr_accessor :id, :min, :max, :step, :implicit, :root, :store

  #####
  # OPERATIONS
  ###

  # constructor
  def initialize(options = {})
    self.store =    options[:store] || @@store
    self.max =      options[:max]
    self.min =      options[:min] || 0
    self.step =     options[:step] || 1
    self.id =       options[:id] || allocateId
    self.implicit = options[:implicit] || false
    self.root =     options[:root] || self

    puts("#{self} -- CREATED") if options[:id] == nil
    #raise ArgumentError, "Min can't be greater than max!" if max && min > max
  end

  # set
  def <<(arg)

    # initialize
    if arg.is_a?(Integer)
      self.min = arg
      self.max = arg
      self.step = 1
    elsif arg.is_a?(DC)
      errorCheckObj(arg)
      self.min = arg.min
      self.max = arg.max
      self.step = arg.step.abs
    else
      raise ArgumentError, "Need Integer or DC"
    end

    # perform transfer
    set(arg)
  end


  # addition
  def +(arg)
    errorCheckObj(self, arg)

    if arg.is_a?(Integer)
      return clone(max: max + arg, min: min + arg)
    end

    if arg.is_a?(DC) && root === arg.root
      return clone(max: max + arg.max, min: min + arg.min, step: step + arg.step)
    end

    if arg.is_a?(DC)

      if leastCountoffCost(arg) == nil
        dc = self.class.new(max: max + arg.max, min: min + arg.min, step: step.gcd(arg.step), implicit: true)
        dc.set(dc.min)
        add(dc)
        arg.add(dc)
        return dc
      end

      if leastCountoffCost(arg) == arg
        arg.max += self.max
        arg.min + self.min
        arg.step = step.gcd(arg.step)
        self.add(arg)
        return arg
      end

      if leastCountoffCost(arg) == self
        self.max += arg.max
        self.min + arg.min
        self.step = step.gcd(arg.step)
        arg.add(self)
        return self
      end

    end

    raise ArgumentError, "+: need Integer or DC"
  end


  # subtraction and negation
  def -(arg)
    self + -arg
  end

  def -@
    self * (-1)
  end

  # multiplication
  def *(arg)

    errorCheckObj(self, arg)

    if arg.is_a?(Integer)
      bounds = [max * other, min * other]
      return clone(max: bounds.max, min: bounds.min, step: step * other)
    end

    if arg.is_a?(DC) && root === arg.root
      # TODO: try to combine dc without using triggers
    end

    if arg.is_a?(DC)
      bounds = [min * other.min, min * other.max, max * other.min, max * other.max]
      dc = DC.temp(max: bounds.max, min: bounds.min, step: step * other.step)
      # TODO: multiplication triggers
      # (X * Y) + (X * B) + (Y * A) + (A * B) - result.min
      freeImplicitObjs(self, arg)
      return dc
    end

    raise ArgumentError, "*: need Integer or DC"
  end


  # division
  def /(arg)
    errorCheckObj(self, arg)

    if arg.is_a?(Integer)
      return clone(max: (max+arg-1) / arg, min: (min+arg-1) / arg, step: (step+arg-1) / arg)
    end

    if arg.is_a?(DC) && root === arg.root
      # TODO: try to combine dc without using triggers
    end

    if arg.is_a?(DC)
      # TODO: do this entire section
    end

    raise ArgumentError, "*: need Integer or DC"
  end


  ##### Counter Implementation details

  def setToAction(other)
    setDeaths("Player 1", "Set to", other, "Terran Marine")
  end

  def addAction(other)
    setDeaths("Player 1", "Add", other, "Terran Marine")
  end

  def subtractAction(other)
    setDeaths("Player 1", "Add", other, "Terran Marine")
  end

  #####
  # TRIGGERS
  ###

  # set DC
  def set(other)
    if other.is_a?(Integer)
      return setToAction(other)
    end

    if other.is_a?(DC)
      other.countoff(self)
    end

    raise ArgumentError
  end

  # add DC
  def add(*args)
    puts "#{root} -- ADD"
    countoff(*args)
  end

  # countoff
  def countoff(*args)
    # prep
    coef = args.last.is_a?(Integer) ? args.last : 1
    objs = args.last.is_a?(Integer) ? args[0..-2] : args

    if objs.empty? || !objs.all? { |obj| obj.is_a?(DC) }
      raise ArgumentError, "Countoff requires DC(s) as input (optional multiplier on end)"
    end

    actions = []

    # allocate temp DC
    if !root.implicit
      temp = self.class.new(
        min: 0,
        max: (root.max - root.min) / root.step,
        implicit: true
      )
    end

    # preliminary
    actions << objs.map { |obj| obj.add(max - min) } if step > 0 && max != 0
    actions << temp.set(0) if !root.implicit
    actions << root.subtract(root.min) if root.min != 0

    # countoff
    power = nearestPower((root.max - root.min) / root.step)
    each_power(power) do |k|
      actions << _if( root >= k * root.step )[
        objs.map { |obj| obj.add(coef * k * step) },

        !root.implicit ?
          [ root.subtract(k * root * step), temp.add(temp + k) ] :
          [ root.subtract(k * root.step) ],
      ]
    end

    # count back
    actions << temp.countoff(root) if !root.implicit

    # post
    actions << root += root.min if !root.implicit && min != 0
    actions << root << 0 if root.implicit

    freeImplicitObjs(self) if root.implicit

    actions
  end


  #####
  # HELPERS
  ###

  def each_power(power, &block)
    k = power
    while k >= 1
      block.call(k)
      k = k / 2
    end
  end

  def nearestPower(num)
    i = 1
    i <<= 1 while 2*i <= num
    i
  end

  # error check
  def errorCheckObj(*objs)
    unless objs.all? { |obj| !obj.is_a?(DC) || obj.bounded? }
      raise ArgumentError, <<-MSG
      DC must have defined bounds before it is used!
      Consider defining bounds when it is declared,
      ie. myDC = DC.new(min: -1, max: 5)"
      MSG
    end
  end

  def bounded?
    min && max
  end

  # least cost for countoff
  def leastCountoffCost(arg)
    if root.implicit == false && arg.implicit == false
      return nil
    elsif root.implicit == true
      return self
    elsif arg.implicit == true
      return arg
    elsif (root.max - root.min) / root.step < (arg.root.max - arg.root.min) / arg.root.step
      return self
    else
      return arg
    end
  end

  def destroy
    self.class.finalize(store, id).call()
    ObjectSpace.undefine_finalizer(self)
    self.id = nil
  end

  def self.finalize(store, id)
    proc do
      puts "DC#{id} -- FREED"
      store.remove(id)
    end
  end

  def freeImplicitObjs(*objs)
    objs.each do |obj|
      obj.destroy if obj.is_a?(DC) && obj.root.implicit
    end
  end

  private

  def allocateId
    new_id = store.allocateId
    ObjectSpace.define_finalizer(self, self.class.finalize(store, new_id))
    new_id
  end

  def clone(options = {})
    # modify cloned dc
    if implicit == true
      self.max =  options[:max]  || max
      self.min =  options[:min]  || min
      self.step = options[:step] || step
      return self
    end

    # clone dc
    self.class.new(
      max:  options[:max]  || max,
      min:  options[:min]  || min,
      id:   options[:id]   || id,
      step: options[:step] || step,
      implicit: true,
      root: self,
    )
  end

  def to_s
    "DC#{id}"
    # max == nil ? "DC#{id} [undefined]" : "DC#{id} [#{min}..#{max}, step=#{step}]"
  end

  def inspect
    "DC#{id}"
  end

end
