require 'test_helper'

class Integrative::Test < ActiveSupport::TestCase
  def setup
    frank = FactoryGirl.create(:user, name: "Frank")
    mark = FactoryGirl.create(:user, name: "Mark")
    FactoryGirl.create(:category, name: "Frankist", user: frank)
    FactoryGirl.create(:category, name: "Marxist", user: mark)
  end

  test "integrates other model when called on relation" do
    users = User.limit(1000).integrate(:category).to_a
    category_names = users.map(&:category).map(&:name)
    assert_equal category_names, ["Frankist", "Marxist"]
  end

  test "integrates other model when called on model" do
    users = User.integrate(:category).to_a
    category_names = users.map(&:category).map(&:name)
    assert_equal category_names, ["Frankist", "Marxist"]
  end
end

