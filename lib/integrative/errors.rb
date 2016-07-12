module Integrative
  module Errors
    class IntegrationError < StandardError
      attr_accessor :integration

      def initialize(message, integration)
        @integration = integration
        super(message)
      end
    end

    class RuntimeOptionMissingError < IntegrationError
      def initialize(integration)
        message = "You used 'integrate' for #{integration.name} without options," +
          " but the following options are required: " +
          " #{integration.init_options[:requires]}"
        super(message, integration)
      end
    end

    class UnexpectedRuntimeOptionError < IntegrationError
      def initialize(integration)
        required = integration.call_options.keys
        message = "You used 'integrate' for #{integration.name} with unexpected options," +
          " you should define integration like this:" +
          " 'integrates :#{integration.name}, requires: [:#{required.join(", :")}]'"
        super(message, integration)
      end
    end

    class TooManyRuntimeOptionsError < IntegrationError
      def initialize(integration, unexpected_options)
        message = "You used 'integrate' for :#{integration.name}" +
          " on #{integration.integrator_class.name}" +
          " with too many options: #{unexpected_options}"
        super(message, integration)
      end
    end

    class TooLittleRuntimeOptionsError < IntegrationError
      def initialize(integration, missing_options)
        message = "You used 'integrate' for :#{integration.name}" +
          " on #{integration.integrator_class.name}" +
          " with too little options: #{missing_options}"
        super(message, integration)
      end
    end

    class IntegratorError < StandardError
      attr_accessor :integration

      def initialize(message, integrator)
        @integrator = integrator
        super(message)
      end
    end

    class MethodAlreadyExistsError < IntegratorError
      def initialize(integrator, name)
        message = "Method '#{name}' is already defined on #{integrator.name}." +
          " You can not define integration with this name."
        super(message, integrator)
      end
    end

    class IntegrationDefinitionMissingError < IntegratorError
      def initialize(integrator, names)
        message = "You tried to call `integrate` on a class #{integrator.name}" +
          " but this class doesn't have this integration." +
          " add the following line to the class #{integrator.name}:" +
          " 'integrates :#{names.join(', :')}'"
        super(message, integrator)
      end
    end
  end
end
