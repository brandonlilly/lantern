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

  def render
    triggers.map(&:run).flatten.map(&:render).join("\n\n")
  end

  def render_xml
    triggers_xml = triggers.map(&:run).flatten.map(&:render_xml).join("\n\n")

    "<mint>\n#{triggers_xml}\n</mint>"
  end
end
