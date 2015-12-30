require_relative 'and_or'

class Condition
  include AndOr

  attr_accessor :params

  def initialize(options)
    @params = {
      c: options[:c],
      g: options[:g],
      u: options[:u],
      m: options[:m],
      n: options[:n],
      r: options[:r],
    }
  end

  def render
    param_render = params.keys.compact
      .select { |key| key != :c && !params[key].nil? }
      .map {|key| "#{key}: #{params[key]}"}
      .join(', ')
    "<Condition #{params[:c]} (#{param_render})>"
  end

  def render_xml
    param_tags = params
      .reject { |key| params[key].nil? }
      .map { |key, value| "  <cond_#{key}>#{value}</cond_#{key}>" }
      .join("\n")

    "<condition>\n#{param_tags}\n</condition>"
  end

  def type
    params[:c]
  end


  def type?(cond_type)
    cond_type == type
  end

  def to_cond
    self
  end
end
