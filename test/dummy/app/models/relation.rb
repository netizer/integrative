class Relation
  include Integrative::Integrated

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

    first_degree_ids = Friend.select_related_user_ids(options[:with], ids)
    second_degree_ids = Friend.select_related_user_ids(first_degree_ids, ids)
    other_ids = ids - first_degree_ids - second_degree_ids

    format_result(1 => first_degree_ids, 2 => second_degree_ids, nil => other_ids)
  end

  def self.integrative_find(ids, options)
    response = find(ids, options)
    response.map { |item| self.new(item) }
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
