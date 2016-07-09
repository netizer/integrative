class Category < ApplicationRecord
  include Integrative::Integrated

  belongs_to :user

  def self.find_and_assign(integrator_records, integration)
    ids = integrator_records.map(&:id)
    response_objects = find(ids)

    response_objects_by_integrator_id = Hash[response_objects.map.with_index { |object, id| [object.user_id, object] }]

    integrator_records.each do |record|
      record.public_send(integration.setter, response_objects_by_integrator_id[record.id])
    end
  end

end
