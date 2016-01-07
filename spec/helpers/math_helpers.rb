require_relative '../../lib/conditions'
require_relative '../../lib/actions'
require_relative '../../lib/trigger'
require_relative '../../lib/and_or'

def each_value(trigger, vars, &test_block)
  unfolded_trigs = trigger.unfold.reject(&:superfluous?)

  ranges = vars.map(&:range)
  permutations = ranges.size > 1 ?
    ranges.map(&:to_a).inject(&:product).map(&:flatten) :
    ranges[0].map {|val| [val]}

  permutations.each do |permutation|
    switches = Array.new(256, false)
    dc_values = Hash.new{|h,k| h[k] = Hash.new(0) }

    permutation.each_with_index do |value, i|
      vars[i].value = value + 2**31
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

            dc_values[player][unit] %= 2**32
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

            var.value %= 2**32
          end
        end
      end

    end


    values = vars.map {|var| var.value - 2**31}
    test_block.call(*values, *permutation)
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
    amount += 2**31

    Condition.new(
      c: 'Test Counter',
      r: id,
      m: format_qmod(qmod),
      n: (amount) % 2**32
    )
  end

  def action(vmod, amount)
    amount += 2**31 if vmod == :setto

    Action.new(
      c: 'Test Counter',
      n:  format_vmod(vmod),
      gs: (amount) % 2**32,
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
