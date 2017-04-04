require "json_schema/builder/version"
require_relative "builder/schema"

module JsonSchema
  module Builder
    def self.schema(id, description, &block)
      @schema = ::Schema.new(id, description).build(&block)
    end

    def self.to_hash
      @schema
    end

    def self.get_binding
      binding
    end
  end
end
