require_relative '../lib/conditions'
require_relative '../lib/actions'
require_relative '../lib/trigger'
require_relative '../lib/and_or'

def success
  Action.new(
    c: 'Success',
    n: true
  )
end

def each_perm(trigger, vars, &test_block)
  unfolded_trigs = trigger.unfold

  (2 ** vars.size).times do |n|
    vars.each_with_index do |var, i|
      var.value = n.to_s(2).reverse.ljust(vars.size, '0')[i] == '1'
    end

    switches = Array.new(256, false)
    success = false

    unfolded_trigs.each do |trigger|
      run = trigger.conditions.all? do |condition|
        if condition.type?('Switch')
          next switches[condition.params[:r]] == (condition.params[:m] == "is set")
        end

        if condition.type?('Test')
          var = vars.find { |var| var.id == condition.params[:r] }
          next condition.params[:m] == var.value
        end

        raise "Unexpected condition type: #{condition.type}"
      end

      if run
        trigger.actions.each do |action|
          if action.type?('Set Switch')
            id = action.params[:gs]
            switches[id] = case action.params[:n]
            when 'toggle'
              !switches[id]
            when 'set'
              true
            when 'clear'
              false
            end
          end
          if action.type?('Success')
            success = true
          end
        end
      end

    end

    test_block.call(success, *vars.map(&:value))
  end
end

def trigger_passes?(trigger, switch_values, dc_values)
  trigger.conditions.all? do |condition|
    true
  end
end

def each_value(trigger, vars, &test_block)
  unfolded_trigs = trigger.unfold

  ranges = vars.map(&:range)
  permutations = ranges.map(&:to_a).inject(&:product).map(&:flatten)
  permutations.each do |permutation|
    switches = Array.new(256, false)
    dc_values = Hash.new{|h,k| h[k] = Hash.new(0) }
    test_values = Hash.new

    permutation.each_with_index do |value, i|
      vars[i].value = value
    end

    unfolded_trigs.each do |trigger|
      run = trigger.conditions.all? do |condition|
        if condition.type?('Switch')
          next switches[condition.params[:r]] == (condition.params[:m] == "is set")
        end

        if condition.type?('Deaths')
          player = condition.params[:g]
          unit = condition.params[:u]
          qmod = condition.params[:m]
          n = condition.params[:n]
          value = dc_values[player][unit]
          next (case qmod
          when "At least"
            value >= n
          when "At most"
            value <= n
          when "Exactly"
            value == n
          end)
        end

        if condition.type?('Test Counter')
          id = condition.params[:r]
          qmod = condition.params[:m]
          n = condition.params[:n]
          var = vars.find { |var| var.id == id }
          next (case qmod
          when "At least"
            var.value >= n
          when "At most"
            var.value <= n
          when "Exactly"
            var.value == n
          end)
        end

        if condition.type?('Test')
          # Todo
          next true
        end

        raise "Unexpected condition type: #{condition.type}"
      end

      if run
        trigger.actions.each do |action|
          if action.type?('Set Switch')
            id = action.params[:gs]
            switches[id] = case action.params[:n]
            when 'toggle'
              !switches[id]
            when 'set'
              true
            when 'clear'
              false
            end
          end

          if action.type?('Set Deaths')
            player = action.params[:gf]
            unit = action.params[:u]
            n = action.params[:gs]
            vmod = action.params[:n]
            case vmod
            when 'Set To'
              dc_values[player][unit] = n
            when 'Add'
              dc_values[player][unit] += n
            when 'Subtract'
              dc_values[player][unit] -= n
            end
          end

          if action.type?('Test Counter')
            id = action.params[:t]
            vmod = action.params[:n]
            n = action.params[:gs]
            var = vars.find { |var| var.id == id }
            case vmod
            when 'Set To'
              var.value = n
            when 'Add'
              var.value += n
            when 'Subtract'
              var.value -= n
            end
          end
        end
      end

    end

    test_block.call(*vars.map(&:value))
  end
end

class TestSwitch
  include AndOr

  @@index = 0

  attr_accessor :value, :id, :inverted

  def initialize(options = {})
    @id = options[:id] || allocateId
  end

  def allocateId
    @@index += 1
  end

  def set?
    Condition.new(
      c: 'Test',
      r: id,
      m: true
    )
  end

  def clear?
    Condition.new(
      c: 'Test',
      r: id,
      m: false
    )
  end

  def to_cond
    set?
  end

  def clone(options = {})
    self.class.new(
      id: options[:id] || id
    )
  end
end

class TestCounter < Counter
  attr_accessor :id, :range, :value

  @@index = 0

  def post_initialize(options)
    self.id = allocateId
    self.range = options[:range]
    self.value = options[:value]
  end

  def allocateId
    @@index += 1
  end

  def condition(qmod, amount)
    Condition.new(
      c: 'Test Counter',
      r: id,
      m: format_qmod(qmod),
      n: n
    )
  end

  def action(vmod, amount)
    Action.new(
      c: 'Test Counter',
      n:  format_vmod(vmod),
      gs: amount,
      t:  id
    )
  end


  def representation
    "TestCounter#{id}"
  end

  def to_s
    "TestCounter#{id}"
  end
end
