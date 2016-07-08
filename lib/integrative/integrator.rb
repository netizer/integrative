module Integrative
  module Integrator
    extend ActiveSupport::Concern

    included do
    end

    class_methods do
      def integrates(name)
        if !defined?(integrations_defined)
          override_activerecord_relation_methods_for_attachments
          class_attribute :integrations_defined
        end
        self.integrations_defined ||= []
        self.integrations_defined << name
        self.class_eval do
          attr_accessor name
        end
      end

      def integrate(*name)
        all.integrate(*name)
      end

      def override_activerecord_relation_methods_for_attachments
        self::ActiveRecord_Relation.class_eval do
          def integrate(*name_or_names)
            names = [*name_or_names]
            names.each do |name|
              if !klass.integrations_defined.include?(name)
                throw "Unknown attachment '#{name}'"
              end
              @integrations_used ||= []
              @integrations_used << name
            end
            self
          end

          def load
            super
            if @integrations_used.present?
              Rails.logger.info "Integrations fetched for #{@records.length} #{klass.name} records."
              @integrations_used.each do |integration|
                integrated_class = integration.to_s.camelize.constantize

                # TODO:
                #integrator_class = self

                #results = integrated_class.integrative_find(@records, integration)
                to_integrates = integrated_class.find(@records.map(&:id))
                to_integrates_by_id = {}
                to_integrates.each do |to_integrate|
                  to_integrates_by_id[to_integrate.id] = to_integrate
                end
                to_integrates_by_id

                #integrator_class.integrative_assign(@records, results, integration)
                @records.each do |record|
                  record.public_send("#{integration}=", to_integrates_by_id[record.id])
                end
              end
            end
            self
          end
        end
      end
    end
  end
end
