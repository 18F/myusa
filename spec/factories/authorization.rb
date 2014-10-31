FactoryGirl.define do
  factory :authorization do
    association :user
    association :application
  end
end
