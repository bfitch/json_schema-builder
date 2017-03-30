require 'pp'
require 'pry'

class Definition
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

  def initialize(schema = nil)
    @schema = schema || Struct.new(:resource).new
    @output = {}
  end

  def build(&block)
    instance_eval(&block) if block_given?
    output
  end

  def uuid(name, description, &block)
    default = {
      description: description,
      example: '6c1ced3f-b74d-435d-ac2a-a15a33ff1d80',
      format: 'uuid',
      type: ['string']
    }

    definition = self.class.new
    definition.instance_eval(&block) if block_given?

    output[name] = default.merge!(definition.output)
  end
  def string(name, description, &block)
    default = {
      description: description,
      example: 'example string',
      type: ['string']
    }

    definition = self.class.new
    definition.instance_eval(&block) if block_given?

    output[name] = default.merge!(definition.output)
  end
  def date(name, description, &block)
    default = {
      description: description,
      example: '2012-01-01',
      format: 'date',
      type: ['string']
    }

    definition = self.class.new
    definition.instance_eval(&block) if block_given?

    output[name] = default.merge!(definition.output)
  end
  def date_time(name, description, &block)
    default = {
      description: description,
      example: '2012-01-01T12:00:00Z',
      format: 'date-time',
      type: ['string']
    }

    definition = self.class.new
    definition.instance_eval(&block) if block_given?

    output[name] = default.merge!(definition.output)
  end
  def enum(name, description, &block)
    default = { description: description }

    definition = self.class.new
    definition.instance_eval(&block) if block_given?

    output[name] = default.merge!(definition.output)
  end

  def array(name, description, &block)
    default = {
      description: description,
      type: ['array'],
      items: {}
    }

    definition = self.class.new(@schema)
    definition.instance_eval(&block) if block_given?

    output[name] = default.merge!({ items: definition.output })
  end

  def properties(&block)
    definition = self.class.new(@schema)
    definition.instance_eval(&block) if block_given?
    @output[:properties] = definition.output
  end

  def one_of(&block)
    @output[:oneOf] = []

    definition = self.class.new(@schema)
    definition.instance_eval(&block)

    @output[:oneOf] << definition.output
  end

  def object(description, &block)
    default = {
      description: description,
      type: ['object']
    }

    definition = self.class.new(@schema)
    definition.instance_eval(&block)

    @output = default.merge!(definition.output)
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

      @output[property] = {
        :$ref => "/schemata/#{@schema.resource}#/definitions/#{reference}"
      }
    end
  end

  def description(description)
    output[:description] = description
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
