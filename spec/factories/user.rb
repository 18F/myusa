FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    sign_in_count 42

    trait :new_user do
      sign_in_count 0
    end

    trait :with_profile do
      profile
    end

    trait :with_full_profile do
      full_profile
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
