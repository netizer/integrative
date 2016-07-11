module Integrative
  module Integrated
    extend ActiveSupport::Concern

    included do
    end

    class_methods do
      def integrative_find(ids, options)
        find(ids)
      end

      def integrative_find_and_assign(integrator_records, integration)
        ids = integrator_records.map(&integration.integrator_key)
        integrated = integrative_find(ids, integration)
        integrated_by_integrator_id =
          array_to_hash(integrated, integration.integrated_key)
        integrator_records.each do |record|
          record.public_send(integration.setter, integrated_by_integrator_id[record.id])
        end
      end

      private

      def array_to_hash(array, key_method)
        Hash[array.map { |object, id| [object.public_send(key_method), object] }]
      end
    end
  end
end
