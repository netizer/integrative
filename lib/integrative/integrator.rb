module Integrative
  module Integrator
    extend ActiveSupport::Concern

    def integrative_dynamic_method_call(name, integration)
      ivar = "@#{name}"
      if instance_variable_defined? ivar
        instance_variable_get ivar
      else
        Rails.logger.info "Integrations fetched for a single #{self.class.name} record."
        integration.integrated_class.integrative_find_and_assign([self], integration)
        instance_variable_get ivar
      end
    end

    class_methods do
      def integrates(name, options = {})
        if self.instance_methods.include? name
          raise Errors::MethodAlreadyExistsError.new(self, name)
        end
        if !defined?(integrations_defined)
          patch_activerecord_relation_for_integrative
          class_attribute :integrations_defined
        end
        integration = Integration.new(name, self, options)
        self.integrations_defined ||= []
        self.integrations_defined << integration
        self.class_eval do
          attr_accessor name

          define_method name do
            integrative_dynamic_method_call(name, integration)
          end
        end
      end

      def integrate(*name_or_names, **options)
        if all.public_methods.include? :integrate
          all.integrate(*name_or_names, **options)
        else
          raise Errors::IntegrationDefinitionMissingError.new(self, name_or_names)
        end
      end

      def patch_activerecord_relation_for_integrative
        self::ActiveRecord_Relation.class_eval do
          def integrate(*name_or_names, **options)
            names = [*name_or_names]
            names.each do |name|
              integration = klass.integrations_defined.find { |i| i.name == name }
              if integration.nil?
                raise Errors::IntegrationDefinitionMissingError.new(klass, [name])
              end
              integration.call_options = options
              integration.invalidate
              @integrations_used ||= []
              @integrations_used << integration
            end
            self
          end

          def load
            super
            if @integrations_used.present?
              Rails.logger.info "Integrations fetched for #{@records.length} #{klass.name} records."
              @integrations_used.each do |integration|
                integration.integrated_class.integrative_find_and_assign(@records, integration)
              end
            end
            self
          end
        end
      end
    end
  end
end
