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
        next switches[condition.params[:r]] == condition.params[:m] if condition.type?('Switch')

        if condition.type?('Test')
          var = vars.find { |var| var.id == condition.params[:r] }
          next condition.params[:m] == var.value
        end

        raise "Unexpected condition type: #{condition.type}"
      end

      if run
        trigger.actions.each do |action|
          if action.type?('Set Switch')
            switches[action.params[:gs]] = action.params[:n] == "set"
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
    @inverted = options.fetch(:inverted, false)
  end

  def allocateId
    @@index += 1
  end

  def set?
    Condition.new(
      c: 'Test',
      r: id,
      m: inverted ? false : true
    )
  end

  def clear?
    Condition.new(
      c: 'Test',
      r: id,
      m: inverted ? true : false
    )
  end

  def to_cond
    set?
  end

  def !
    clone(inverted: !inverted)
  end

  def clone(options = {})
    self.class.new(
      id:       options[:id] || id,
      implicit: options.fetch(:inverted, inverted)
    )
  end
end
