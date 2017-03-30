require_relative 'definition'

class Payloads
  attr_accessor :output

  def initialize(schema)
    @schema = schema
    @output = {}
  end

  def build(&block)
    instance_eval(&block)
    output
  end

  def request(name, description, &block)
    output[name] = {
      description: description,
      type: ["object"],
      properties: { }
    }
    output[name][:properties] = ::Definition.new(@schema).build(&block)
  end

  def response
  end
end
