require_relative 'definition'
require 'pry'

class Definitions
  attr_accessor :output

  def initialize(schema)
    @schema = schema
    @output = {}
  end

  def build(&block)
    output.merge!(::Definition.new(@schema).build(&block))
    output
  end

  def import(name, klass)
  # figure this out
  end
end
