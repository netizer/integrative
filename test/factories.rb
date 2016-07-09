FactoryGirl.define do
  factory :user do
    name "John"
  end

  factory :category do
    name "Johns"
    association :user
  end

  factory :friend do
    association :user
    association :other_user, factory: :user
  end
end
