module Integrative
  module Extensions
    module RelationExtension
      def integrate(*name_or_names, **options)
        names = [*name_or_names]
        names.each do |name|
          integrate_per_name(name, options)
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

      private

      def integrate_per_name(name, options)
        integration = klass.integrations_defined.find { |i| i.name == name }
        if integration.nil?
          raise Errors::IntegrationDefinitionMissingError.new(klass, [name])
        end
        integration.call_options = options
        integration.invalidate
        @integrations_used ||= []
        @integrations_used << integration
      end
    end
  end
end
