module Integrative
  module Integrated
    extend ActiveSupport::Concern

    included do
    end

    class_methods do
      def integrative_find(ids, options)
        find(ids)
      end

      def integrator_ids(integrator_records, integration)
        integrator_records.map(&integration.integrator_key)
      end

      def integrative_find_and_assign(integrator_records, integration)
        ids = integrator_ids(integrator_records, integration)
        integrated = integrative_find(ids, integration)
        integrated_by_integrator_id = array_to_hash(integrated, integration)
        integrator_records.each do |record|
          record.public_send(integration.setter, integrated_by_integrator_id[record.id])
        end
      end

      private

      def array_to_hash(array, integration)
        if integration.init_options[:array]
          array_to_hash_as_array(array, integration.integrated_key)
        else
          array_to_hash_as_value(array, integration.integrated_key)
        end
      end

      def array_to_hash_as_value(array, key_method)
        Hash[array.map { |object| [object.public_send(key_method), object] }]
      end

      def array_to_hash_as_array(array, key_method)
        result = {}
        array.each do |object|
          key = object.public_send(key_method)
          result[key] ||= []
          result[key] << object
        end
        result
      end
    end
  end
end
