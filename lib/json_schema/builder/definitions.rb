require_relative 'definition'

class Definitions
  attr_accessor :output

  def initialize(schema)
    @schema = schema
    @output = {}
  end

  def build(&block)
    instance_eval(&block)
    output
  end

  def import(name, klass)
  # figure this out
  end

  def ref(mapping)
    name, reference = mapping.to_a.pop
    raise RuntimeError.new("Missing definition: #{reference}") if output[reference].nil?

    output[name] = { :$ref => "/schemata/#{@schema.resource}#/definitions/#{reference}" }
  end

  def method_missing(type, *args, &block)
    name, description = args
    definition = ::Definition.new(@schema)
    output[name] = definition.send(type, description, &block)
  end
end
