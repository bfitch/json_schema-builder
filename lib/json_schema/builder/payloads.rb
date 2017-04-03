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
    default = {
      description: description,
      type: ["object"]
    }
    output[name] = default.merge!(::Definition.new(@schema).build(&block))
  end

  def response(name, description = nil, &block)
    default = {
      type: ["object"]
    }
    default[:description] = description if description
    output[name] = default.merge!(::Definition.new(@schema).build(&block))
  end
end
