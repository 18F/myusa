FactoryGirl.define do
  factory :unsubscribe_token do
    association :user
    association :notification
    token { Faker::Bitcoin.address }
  end
end
