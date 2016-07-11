FactoryGirl.define do
  factory :user do
    name "John"
    association :category
  end

  factory :category do
    name "Johns"
  end

  factory :friend do
    association :user
    association :other_user, factory: :user
  end
end
