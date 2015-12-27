require_relative 'actions'
require_relative 'conditions'
require_relative 'trigger'

class Map
  attr_accessor :triggers

  def initialize(options = {})
    @triggers = options[:triggers] || []
  end

  def _if(*conditions)
    trigger = Trigger.new(conditions: conditions, players: [:P1])
    triggers << trigger
    trigger
  end

  def _always(*actions)
    trigger = Trigger.new(players: [:P1])
    triggers << trigger
    trigger
  end

  def run
    triggers.map(&:run).join("\n\nnjkjnkjnkjn\n\n")
  end
end
