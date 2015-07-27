FactoryGirl.define do
  factory :profile do
    first_name 'Joan'
    last_name 'Public'
    association :user

    factory :full_profile, class: Profile do
      title 'Sir'
      first_name 'Joan'
      middle_name 'Quincy'
      last_name 'Public'
      suffix 'III'
      address '1 Infinite Loop'
      address2 'Attn: Steve Jobs'
      city 'Cupertino'
      state 'CA'
      zip '92037'
      gender 'Female'
      marital_status 'Married'
      is_parent true
      is_student false
      is_veteran true
      is_retired false
      phone '1234567890'
      mobile '1234567890'
    end
  end
end
