require_relative 'actions'
require_relative 'conditions'
require_relative 'trigger'

class Map
  attr_accessor :triggers, :dc_table

  def initialize(options = {})
    @triggers = options[:triggers] || []
    @dc_table = {
      'Alan Turret'     => Array.new(8, :free),
    	'Start Location'  => Array.new(8, :free),
    	'Goliath Turret'  => Array.new(8, :free),
    	'Cantina'         => Array.new(8, :free),
    	'Cave'            => Array.new(8, :free),
    	'Cave-in'         => Array.new(8, :free),
    	'Jump Gate'       => Array.new(8, :free),
    	'Mining Platform' => Array.new(8, :free),
    	'Ruins'           => Array.new(8, :free),
    	'Protoss Marker'  => Array.new(8, :free),
    	'Terran Marker'   => Array.new(8, :free),
    	'Zerg Marker'     => Array.new(8, :free),
    	"Scanner Sweep"   => Array.new(8, :free),
    	"Nuclear Missile" => Array.new(8, :free),
    }
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
    triggers.map(&:run).flatten.map(&:render).join("\n")
  end

  def render_xml
    triggers_xml = triggers.map(&:run).flatten.map(&:render_xml).join("\n\n")

    "<mint>\n#{triggers_xml}\n</mint>"
  end

  def generate
    triggers.map do |trigger|
      trigger.generate(dc_table)
    end
  end
end
