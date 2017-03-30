require_relative 'definitions'
require_relative 'payloads'

class Schema
  attr_accessor :output, :resource

  def initialize(resource, description)
    @resource = resource
    @output = {
      id: "schemata/#{resource}",
      type: ["object"],
      description: description
    }
  end

  def build(&block)
    instance_eval(&block)
    output
  end

  def spec(url)
    output[:$schema] = url
  end

  def title(title)
    output[:title] = title
  end

  def definitions(&block)
    output[:definitions] = ::Definitions.new(self).build(&block)
  end

  def payloads(&block)
    output[:payloads] = ::Payloads.new.build(&block)
  end

  def links(&block)
  end

  def properties(&block)
  end
end
