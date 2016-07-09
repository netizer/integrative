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

    first_degree_friends = Friend.where(user: options[:user], other_user_id: ids).all
    first_degree_friend_ids = first_degree_friends.map(&:other_user_id)

    second_degree_friends = Friend.where(user_id: first_degree_friend_ids, other_user_id: ids).all
    second_degree_friend_ids = second_degree_friends.map(&:other_user_id)

    other_friend_ids = ids - first_degree_friend_ids - second_degree_friend_ids

    firsts = first_degree_friends.map { |friend| {degree: 1, user_id: friend.other_user_id} }
    seconds = second_degree_friends.map { |friend| {degree: 2, user_id: friend.other_user_id} }
    others = other_friend_ids.map { |id| {degree: nil, user_id: id} }

    firsts + seconds + others
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
end
