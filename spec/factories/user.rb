FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "user_#{n}@gsa.gov" }
    sign_in_count 42

    trait :new_user do
      sign_in_count 0
    end

    trait :with_profile do
      profile
    end

    trait :with_google do
      after(:create) do |user|
        create_list(:google_authentication, 1, user: user)
      end
    end

    factory :admin_user do
      after(:create) {|u| u.grant_role!(:admin) }
    end

    trait :with_2fa do
      mobile_number '800-555-3455'
    end

  end
end
