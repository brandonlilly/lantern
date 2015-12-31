class Action
  attr_accessor :params

  def initialize(options)
    @params = {
      c:  options[:c],
      gf: options[:gf],
      n:  options[:n],
      gs: options[:gs],
      u:  options[:u],
      s:  options[:s],
      l:  options[:l],
      t:  options[:t],
    }
  end

  def render
    param_render = params.keys.compact
      .select { |key| key != :c && !params[key].nil? }
      .map {|key| "#{key}: #{params[key]}"}
      .join(", ")
    "<Action #{params[:c]} (#{param_render})>"
  end

  def render_xml
    param_tags = params
      .reject { |key| params[key].nil? }
      .map { |key, value| "  <act_#{key}>#{value}</act_#{key}>" }
      .join("\n")

    "<action>\n#{param_tags}\n</action>"
  end

  def type
    params[:c]
  end

  def type?(action_type)
    action_type == type
  end

  def to_s
    inspect
  end
end
