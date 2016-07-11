module Integrative
  module Integrator
    extend ActiveSupport::Concern

    included do
    end

    class_methods do
      def integrates(name, options = {})
        if !defined?(integrations_defined)
          patch_activerecord_relation_for_integrative
          class_attribute :integrations_defined
        end
        self.integrations_defined ||= []
        self.integrations_defined << Integration.new(name, self, options)
        if self.instance_methods.include? name
          raise "Method '#{name}' is already defined on #{self.name}." +
            " You can not define integration with this name."
        end
        self.class_eval do
          attr_accessor name
        end
      end

      def integrate(*name_or_names, **options)
        if all.public_methods.include? :integrate
          all.integrate(*name_or_names, **options)
        else
          raise "You tried to call `integrate` on a class #{name}" +
            " but this class has no integrations." +
            " add the following line to the class #{name}:" +
            " 'integrates :#{name_or_names.join(', :')}'"
        end
      end

      def patch_activerecord_relation_for_integrative
        self::ActiveRecord_Relation.class_eval do
          def integrate(*name_or_names, **options)
            names = [*name_or_names]
            names.each do |name|
              integration = klass.integrations_defined.find { |integration| integration.name == name }
              if integration.nil?
                raise "Unknown integration '#{name}'"
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
