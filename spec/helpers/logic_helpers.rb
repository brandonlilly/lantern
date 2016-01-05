require_relative '../../lib/conditions'
require_relative '../../lib/actions'
require_relative '../../lib/trigger'
require_relative '../../lib/and_or'

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
