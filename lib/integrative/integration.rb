module Integrative
  class Integration
    attr_accessor :name
    attr_accessor :integrator_class
    attr_accessor :integrated_class
    attr_accessor :init_options
    attr_accessor :call_options

    def initialize(name, integrator_class, options)
      @name = name
      @integrator_class = integrator_class
      @integrated_class = name.to_s.camelize.singularize.constantize
      @init_options = options
    end

    def invalidate
      if call_options.blank? && init_options[:requires].present?
        raise Errors::RuntimeOptionMissingError.new(self)
      end

      if call_options.present? && init_options[:requires].blank?
        raise Errors::UnexpectedRuntimeOptionError.new(self)
      end

      if call_options.present? && init_options[:requires].present?
        unexpected_options = call_options.keys - init_options[:requires]
        missing_options = init_options[:requires] - call_options.keys

        if unexpected_options.present?
          raise Errors::TooManyRuntimeOptionsError.new(self, unexpected_options)
        end

        if missing_options.present?
          raise Errors::TooLittleRuntimeOptionsError.new(self, missing_options)
        end
      end
    end

    def setter
      "#{name}="
    end

    def integrator_key
      init_options[:integrator_key] || :id
    end

    def integrated_key
      default_integrated_key = "#{integrator_class.name.underscore}_id"
      init_options[:integrated_key] || default_integrated_key
    end
  end
end
