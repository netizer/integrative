require 'test_helper'

class Integrative::Test < ActiveSupport::TestCase
  def setup
    @frank = FactoryGirl.create(:user, name: "Frank")
    @mark = FactoryGirl.create(:user, name: "Mark")
    FactoryGirl.create(:category, name: "Frankist", user: @frank)
    FactoryGirl.create(:category, name: "Marxist", user: @mark)
  end

  test "integrates AR models when called on relation" do
    users = User.limit(1000).integrate(:category).to_a

    category_names = users.map(&:category).map(&:name)
    assert_equal category_names, ["Frankist", "Marxist"]
  end

  test "integrates AR models when called on model" do
    users = User.integrate(:category).to_a

    category_names = users.map(&:category).map(&:name)
    assert_equal category_names, ["Frankist", "Marxist"]
  end

  test "integrates non-AR models" do
    users = User.integrate(:facebook).to_a

    facebook_names = users.map(&:facebook).map(&:name)
    assert_equal facebook_names, ["FB name of Frank", "FB name of Mark"]
  end

  test "integrates models with options" do
    ana = create(:user, name: "Ana")
    maria = create(:user, name: "Maria")
    create_friendship(@frank, ana)
    create_friendship(ana, maria)

    users_with_relations = User.where.not(id: @frank.id).integrate(:relation, user: @frank)

    relations_per_user = users_with_relations.map do |user|
      [user.name, user.relation.kind]
    end
    assert_equal relations_per_user, [["Mark", :not_a_friend],
      ["Ana", :first_degree_friend], ["Maria", :second_degree_friend]]
  end

  test "integrates models with guessed association key" do
    skip "In the middle of work here"
    #categories = Category.integrate(:recently_added_user).to_a

    #category_and_user_names = categories.map { |category| [category.name, category.user.name] }
    #assert_equal category_names, [["Frankist", "Frank"], ["Marxist", "Mark"]]
  end

  def create_friendship(user, other_user)
    FactoryGirl.create(:friend, user: user, other_user: other_user)
    FactoryGirl.create(:friend, user: other_user, other_user: user)
  end
end

