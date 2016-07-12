require 'ostruct'

module Integrative
  module Integrated
    extend ActiveSupport::Concern

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

      def integrative_value(object, integration)
        if [:primary, :value, :simple].include? integration.init_options[:as]
          object[:value]
        else
          object
        end
      end

      private

      def array_to_hash(array, integration)
        if integration.init_options[:array]
          array_to_hash_as_array(array, integration)
        else
          array_to_hash_as_value(array, integration)
        end
      end

      def array_to_hash_as_value(array, integration)
        result = array.map do |object|
          key = object.public_send(integration.integrated_key)
          [key, integrative_value(object, integration)]
        end
        Hash[result]
      end

      def array_to_hash_as_array(array, integration)
        result = {}
        array.each do |object|
          key = object.public_send(integration.integrated_key)
          result[key] ||= []
          result[key] << integrative_value(object, integration)
        end
        result
      end
    end
  end
end
