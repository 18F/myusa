FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "user_#{n}@gsa.gov" }
  end
end
