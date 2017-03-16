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

  def ref(name, references:)
    raise RuntimeError.new("Missing definition: #{references}") if output[references].nil?

    output[name] = {
      :$ref => "/schemata/#{@schema.resource}#/definitions/#{references}"
    }
  end

  def method_missing(type, *args, &block)
    name, description = args
    output[name] = Definition.new(type, description).build(&block)
  end

  class Definition
    attr_accessor :output, :factory

    def initialize(factory, description)
      @factory = factory
      @output = {
        description: description
      }
      set_defaults
    end

    def build(&block)
      instance_eval(&block) if block_given?
      output
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

    private

    def set_defaults
      case factory
      when :uuid
        output.merge!({format: 'uuid', type: 'string'})
      when :string
        output.merge!({type: 'string'})
      end
    end
  end
end
