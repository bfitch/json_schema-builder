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

  attr_accessor :output, :type_def

  def initialize(type_def, arguments, schema = nil)
    @schema = schema || Struct.new(:resource).new
    @type_def = type_def

    if arguments.is_a?(String)
      @output = { description: arguments }.merge!(defaults)
    else
      @output = {}
    end
  end

  def build(&block)
    instance_eval(&block) if block_given?
    output
  end

  def ref(reference)
    raise RuntimeError.new("A ref can only be declared in array definitions.") if type_def != :array

    if reference.to_s == @schema.resource
      output[:items] = { :$ref => "/schemata/#{@schema.resource}" }
    else
      output[:items] = { :$ref => "/schemata/#{@schema.resource}#/definitions/#{reference}" }
    end
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

  def defaults
    case type_def
    when :uuid
      {
        example: '6c1ced3f-b74d-435d-ac2a-a15a33ff1d80',
        format: 'uuid',
        type: ['string']
      }
    when :string
      {
        example: 'example string',
        type: ['string']
      }
    when :date
      {
        example: '2012-01-01',
        format: 'date',
        type: ['string']
      }
    when :date_time
      {
        example: '2012-01-01T12:00:00Z',
        format: 'date-time',
        type: ['string']
      }
    when :array
      {
        type: ['array'],
        items: {}
      }
    else
      {}
    end
  end
end
