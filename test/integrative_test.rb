require 'test_helper'

class Integrative::Test < ActiveSupport::TestCase
  def setup
    @category1 = FactoryGirl.create(:category, name: "Frankist")
    @category2 = FactoryGirl.create(:category, name: "Marxist")
    @frank = FactoryGirl.create(:user, name: "Frank", category: @category1)
    @mark = FactoryGirl.create(:user, name: "Mark", category: @category2)
  end

  test "integrates models when called on a model" do
    users = User.integrate(:facebook).to_a

    facebook_names = users.map(&:facebook).map(&:name)
    assert_equal facebook_names, ["FB name of Frank", "FB name of Mark"]
  end

  test "integrates models when called on a Relation object" do
    users = User.all.integrate(:facebook).to_a

    facebook_names = users.map(&:facebook).map(&:name)
    assert_equal facebook_names, ["FB name of Frank", "FB name of Mark"]
  end

  test "integrates models with options" do
    ana = create(:user, name: "Ana")
    maria = create(:user, name: "Maria")
    create_friendship(@frank, ana)
    create_friendship(ana, maria)

    users_with_relations = User.where.not(id: @frank.id).integrate(:relation, with: @frank)

    relations_per_user = users_with_relations.map do |user|
      [user.name, user.relation.kind]
    end
    assert_equal relations_per_user, [["Mark", :not_a_friend],
      ["Ana", :first_degree_friend], ["Maria", :second_degree_friend]]
  end

  test "integrates models with guessed association key" do
    create(:user, name: "Fran", category: @category1)
    create(:user, name: "Mar", category: @category2)
    categories = Category.integrate(:recently_added_user).to_a

    category_and_user_names = categories.map do |category|
      [category.name, category.recently_added_user.name]
    end
    assert_equal category_and_user_names, [["Frankist", "Fran"], ["Marxist", "Mar"]]
  end

  test "integrates models as arrays" do
    users = User.integrate(:flags).to_a

    users_with_flags = users.map { |user| [user.name, user.flags.map(&:name)] }
    assert_equal users_with_flags, [["Frank", [:admin, :editor]], ["Mark", [:editor]]]
  end

  test "integrates models as primary data types" do
    users = User.integrate(:gravatar).to_a

    users_with_flags = users.map { |user| [user.name, user.gravatar] }
    assert_equal users_with_flags, [
      ["Frank", "http://0.gravatar.com/avatar/frank"],
      ["Mark", "http://0.gravatar.com/avatar/mark"]
    ]
  end

  test "integrate single model when its method is called" do
    assert_equal @frank.gravatar, "http://0.gravatar.com/avatar/frank"
  end

  test "integrated models when called on array of objects" do
    users = User.all.to_a

    Integrative.integrate_into(users, :facebook)

    facebook_names = users.map(&:facebook).map(&:name)
    assert_equal facebook_names, ["FB name of Frank", "FB name of Mark"]
  end

  test "raises Error when integrate option is missing" do
    assert_raises Integrative::Errors::RuntimeOptionMissingError do
      User.integrate(:relation)
    end
  end

  test "raises Error when integrate is called with option and none is expected" do
    assert_raises Integrative::Errors::UnexpectedRuntimeOptionError do
      User.integrate(:facebook, with: User.first)
    end
  end

  test "raises Error when integrate is called with more options than needed" do
    assert_raises Integrative::Errors::TooManyRuntimeOptionsError do
      User.integrate(:relation, with: User.first, and: :voila)
    end
  end

  test "raises Error when integrate is called with less options than needed" do
    assert_raises Integrative::Errors::TooLittleRuntimeOptionsError do
      Category.integrate(:flag, a: 1)
    end
  end

  test "raises Error when integrates is called with name of existing method" do
    assert_raises Integrative::Errors::MethodAlreadyExistsError do
      User.class_eval do
        integrates :category
      end
    end
  end

  test "raises Error when integrate is called on a model that has no integrations" do
    assert_raises Integrative::Errors::IntegrationDefinitionMissingError do
      Friend.integrate(:facebook)
    end
  end

  test "raises Error when integrate is called but the integration is not defined" do
    assert_raises Integrative::Errors::IntegrationDefinitionMissingError do
      User.integrate(:twitter)
    end
  end

  def create_friendship(user, other_user)
    FactoryGirl.create(:friend, user: user, other_user: other_user)
    FactoryGirl.create(:friend, user: other_user, other_user: user)
  end
end

