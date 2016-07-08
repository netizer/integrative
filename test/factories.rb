FactoryGirl.define do
  factory :user do
    name "John"
  end

  factory :category do
    name "Johns"
    user
  end
end
