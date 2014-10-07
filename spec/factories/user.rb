FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "user_#{n}@gsa.gov" }

    trait :with_profile do
      profile
    end
    
    trait :with_google do
      after(:create) do |user|
        create_list(:google_authentication, 1, user: user)
      end
    end

  end
end
