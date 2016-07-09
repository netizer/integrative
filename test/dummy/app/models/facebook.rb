class Facebook
  include Integrative::Integrated

  attr_accessor :id
  attr_accessor :user_id
  attr_accessor :name

  def initialize(data)
    @id = data[:id]
    @user_id = data[:user_id]
    @name = data[:name]
  end

  # naive representation of the case when we want to fetch data through external API
  def self.fetch(ids)
    ids.map do |id|
      user = User.find(id)
      {
        id: id,
        user_id: user.id,
        name: "FB name of #{user.name}"
      }
    end
  end

  def self.find_and_assign(integrator_records, integration)
    ids = integrator_records.map(&:id)

    response = fetch(ids)
    response_objects = response.map { |item| self.new(item) }

    response_objects_by_integrator_id = Hash[response_objects.map.with_index { |object, id| [object.user_id, object]}]

    integrator_records.each do |record|
      record.public_send(integration.setter, response_objects_by_integrator_id[record.id])
    end
  end

end
