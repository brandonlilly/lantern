require_relative 'actions'
require_relative 'conditions'
require_relative 'switch'

class Trigger
  attr_accessor :conditions, :actions, :preserved, :players

  def initialize(options = {})
    @conditions = options[:conditions] || []
    @actions =    options[:actions] || []
    @preserved =  options.fetch(:preserved, true)
    @players =    options[:players] || []
  end

  def _if(*conds)
    conditions << conds
    self
  end

  def [](*actns)
    actions.concat(actns)
    self
  end

  def render
    conditions_render = conditions.map(&:render).join("\n")
    actions_render = actions.map(&:render).join("\n")

    "TRIGGER #{players.join(", ")}\nCONDITIONS\n#{conditions_render}\nACTIONS\n#{actions_render}\nEND\n\n"
  end

  def render_xml
    conditions_xml = conditions.map(&:render_xml).join("\n")
    actions_xml = actions.map(&:render_xml).join("\n")
    players_xml = players.map { |player| "<trig_group>#{player}</trig_group>" }.join("\n")
    trig_xml = preserved ? "<trigp/>" : "<trig/>"

    "#{players_xml}\n#{trig_xml}\n#{conditions_xml}\n#{actions_xml}"
  end

  def run
    unfold.reject(&:superfluous?)
  end

  def child_trigger(options)
    Trigger.new(options)
  end

  def unfold
    trigs = []
    current_trig = Trigger.new(players: players)
    cond_switches = []

    conditions.flatten.each do |condition|
      if condition.is_a?(Condition) || condition.class.method_defined?(:to_cond)
        current_trig.conditions << condition.to_cond
      end

      if condition.is_a?(Conditional)
        if !condition.inverted
          cond = Switch.new(name: 'COND')
          cond_switches << cond

          block_actions = condition.action_block.call(cond)
          current_trig.actions << [ cond << false, block_actions ]
          trigs.concat(current_trig.unfold)
          current_trig = Trigger.new(conditions: [cond.set?], players: players)
        else
          cond = Switch.new(name: 'COND')
          temp = Switch.new(name: 'TEMP')
          cond_switches << cond
          cond_switches << temp

          block_actions = condition.action_block.call(cond)
          current_trig.actions << [
            cond << false,
            temp << true,
            block_actions,
          ]
          trigs.concat(current_trig.unfold)
          current_trig = Trigger.new(
            players: players,
            conditions: [cond.clear?, temp.set?]
          )
        end
      end
    end

    actions.flatten.each do |action|
      if action.is_a?(Trigger)
        temp = Switch.new(name: 'NEST')
        current_trig.actions << (temp << true)
        trigs << current_trig
        trigger = action
        trigger.players = players
        trigger.conditions.unshift(temp.set?)
        trigs.concat(trigger.unfold)
        current_trig = Trigger.new(conditions: [temp.set?], actions: [temp.clear], players: players)
        next
      else
        current_trig.actions << action
      end
    end
    trigs << current_trig

    unless cond_switches.empty?
      trigs << Trigger.new(actions: cond_switches.map(&:clear), players: players)
      cond_switches.each(&:clear)
    end

    trigs
  end

  def superfluous?
    actions.empty? || scs? || has_never?
    false
  end

  private

  # check if trigger just clears then sets same switch
  def scs?
    conditions.size == 1 &&
    actions.size == 2 &&
    conditions[0].type?("Switch") &&
    actions[0].type?("Set Switch") &&
    actions[1].type?("Set Switch") &&
    conditions[0].params[:r] == actions[0].params[:gs] &&
    actions[1].params[:gs] == actions[0].params[:gs] &&
    conditions[0].params[:m] == "is set" &&
    actions[0].params[:n] == "clear" &&
    actions[1].params[:n] == "set"
  end

  def has_never?
    conditions.any? {|condition| condition.type?("Never") }
  end
end

def _if(*conditions)
  Trigger.new(conditions: conditions)
end
