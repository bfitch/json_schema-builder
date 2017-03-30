require 'pp'

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

  def uuid(description, &block)
    @output = {
      description: description,
      example: '6c1ced3f-b74d-435d-ac2a-a15a33ff1d80',
      format: 'uuid',
      type: ['string']
    }
    instance_eval(&block) if block_given?
    output
  end
  def string(description, &block)
    @output = {
      description: description,
      example: 'example string',
      type: ['string']
    }
    instance_eval(&block) if block_given?
    output
  end
  def date(description, &block)
    @output = {
      description: description,
      example: '2012-01-01',
      format: 'date',
      type: ['string']
    }
    instance_eval(&block) if block_given?
    output
  end
  def date_time(description, &block)
    @output = {
      description: description,
      example: '2012-01-01T12:00:00Z',
      format: 'date-time',
      type: ['string']
    }
    instance_eval(&block) if block_given?
    output
  end
  def array(*args, &block)
    default = {}

    if args.size == 2
      name, description = args
    else
      description = args.pop
    end

    if (name)
      default[name] = {
        description: description,
        type: ['array'],
        items: {}
      }
      instance_eval(&block) if block_given?
      default[name][:items] = output
    else
      default = {
        description: description,
        type: ['array'],
        items: {}
      }
      instance_eval(&block) if block_given?
      default[:items] = output
    end

    @output = default
  end

  def enum(description, &block)
    default = { description: description }
    instance_eval(&block)

    @output.merge!(default)
  end

  def ref(reference)
    if reference.to_s == @schema.resource
      output[:$ref] = "/schemata/#{@schema.resource}"
    else
      output[:$ref] = "/schemata/#{@schema.resource}#/definitions/#{reference}"
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
