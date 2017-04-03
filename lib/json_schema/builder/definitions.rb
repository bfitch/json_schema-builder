require_relative 'definition'
require 'pry'

class Definitions
  attr_accessor :output

  def initialize(schema)
    @schema = schema
    @definition = ::Definition.new(@schema)
    @output = {}
  end

  def build(&block)
    output.merge!(@definition.build(&block))
    output
  end
end
