class Relation
  attr_accessor :kind
  attr_accessor :user_id

  def initialize(options)
    @kind = case options[:degree]
    when 1
      :first_degree_friend
    when 2
      :second_degree_friend
    else
      :not_a_friend
    end
    @user_id = options[:user_id]
  end

  def self.find(ids, options)
    user = options[:user]

    first_degree_ids = Friend.select_related_user_ids(options[:user], ids)
    second_degree_ids = Friend.select_related_user_ids(first_degree_ids, ids)
    other_ids = ids - first_degree_ids - second_degree_ids

    format_result(1 => first_degree_ids, 2 => second_degree_ids, nil => other_ids)
  end

  def self.find_and_assign(integrator_records, integration)
    ids = integrator_records.map(&:id)

    response = find(ids, integration.call_options)
    response_objects = response.map { |item| self.new(item) }

    response_objects_by_integrator_id = Hash[response_objects.map.with_index { |object, id| [object.user_id, object]}]

    integrator_records.each do |record|
      record.public_send(integration.setter, response_objects_by_integrator_id[record.id])
    end
  end

  private

  def self.format_result(degree_hash)
    result = []
    degree_hash.map do |degree, ids|
      result += with_degree(ids, degree)
    end
    result
  end

  def self.with_degree(user_ids, degree)
    user_ids.map { |user_id| {degree: degree, user_id: user_id} }
  end
end
