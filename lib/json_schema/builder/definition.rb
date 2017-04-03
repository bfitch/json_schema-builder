require_relative 'types'

class Definition
  include JsonSchema::Builder::Types

  TYPE_MAP = {
    Array => 'array',
    TrueClass => 'boolean',
    FalseClass => 'boolean',
    Fixnum => 'integer',
    Float => 'number',
    NilClass => 'null',
    Hash => 'object',
    String => 'string'
  }

  # formats
  # ["date", "date-time", "email", "hostname", "ipv4", "ipv6", "uri"] or defined by us ["uuid"]

  attr_accessor :output

  def initialize(schema = nil, options = {})
    @schema = schema || Struct.new(:resource).new
    @options = options
    @output = {}
  end

  def build(&block)
    instance_eval(&block) if block_given?
    output
  end

  def import(name, klass)
    proc = klass.new.send(name)
    definition = self.class.new(@schema)
    definition.instance_eval(&proc)

    @output = @output.merge!(definition.output)
  end

  def properties(&block)
    definition = self.class.new(@schema)
    definition.instance_eval(&block) if block_given?
    @output[:properties] = definition.output
  end

  def one_of(&block)
    @output[:oneOf] = []

    definition = self.class.new(@schema, one_of: true)
    definition.instance_eval(&block)

    @output[:oneOf] = definition.output[:oneOf]
  end

  def ref(mapping)
    if (mapping.is_a?(Symbol))
      reference = mapping
      if reference.to_s == @schema.resource
        @output[:$ref] = "/schemata/#{@schema.resource}"
      else
        @output[:$ref] = "/schemata/#{@schema.resource}#/definitions/#{reference}"
      end
    else
      property, reference = mapping.to_a.pop

      if reference.to_s == @schema.resource
        @output[property] = { :$ref => "/schemata/#{@schema.resource}" }
      else
        @output[property] = {
          :$ref => "/schemata/#{@schema.resource}#/definitions/#{reference}"
        }
      end
    end

  end

  def description(description)
    output[:description] = description if description
  end

  def example(example)
    output[:example] = example
  end

  def format(format)
    output[:format] = format
  end

  def type(type)
    output[:type] = type
  end

  def required(properties)
    output[:required] = properties
  end

  def additional_properties(bool)
    output[:additionalProperties] = bool
  end

  def values(values)
    output[:enum] = values
    output[:type] = output[:type] || json_types(values)
  end

  private

  def json_types(values)
    ruby_classes = values.map(&:class).uniq
    ruby_classes.map { |klass| TYPE_MAP[klass] }
  end
end
