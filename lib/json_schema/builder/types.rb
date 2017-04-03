module JsonSchema
  module Builder
    module Types
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

      def string(name = nil, description = nil, &block)
        if name.is_a?(Symbol)
          name = name
        elsif name.is_a?(String)
          description = name
        end

        default = { type: ['string'] }
        default[:description] = description if description

        definition = self.class.new
        definition.instance_eval(&block) if block_given?

        if @options[:one_of]
          @output[:oneOf] = [] if @output.empty?
          @output[:oneOf] << default.merge!(definition.output)
        else
          if name
            output[name] = default.merge!(definition.output)
          else
            output = default.merge!(definition.output)
          end
        end
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

      def array(name = nil, description = nil, &block)
        default = {
          type: ['array'],
          items: {}
        }
        default[:description] = description if description

        definition = self.class.new(@schema)
        definition.instance_eval(&block) if block_given?

        if name
          output[name] = default.merge!({ items: definition.output })
        else
          output = default.merge!({ items: definition.output })
        end
      end

      def object(name =nil, description = nil, &block)
        if name.is_a?(Symbol)
          name = name
        elsif name.is_a?(String)
          description = name
        end

        default = { type: ['object'] }
        default[:description] = description if description

        definition = self.class.new(@schema)
        definition.instance_eval(&block)

        if @options[:one_of]
          @output[:oneOf] = [] if @output.empty?
          @output[:oneOf] << default.merge!(definition.output)
        else
          props = default.merge!(definition.output)
          if name
            @output[name] = props
          else
            @output = props
          end
        end
      end
    end
  end
end
