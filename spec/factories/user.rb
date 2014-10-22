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
      with_mobile_number
      after(:create) {|u| u.has_role!(:admin) }
    end

    trait :with_mobile_number do
      # we are currently storing the mobile number for SMS recovery and 2FA in
      # the user's profile ... this will need to change when we move it.
      # profile { create(:profile, mobile_number: '800-555-3455') }
      ignore { mobile_number '800-555-3455' }
      after(:create) {|u, e| u.profile.update_attributes(mobile_number: e.mobile_number)}
    end

  end
end
