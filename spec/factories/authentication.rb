FactoryGirl.define do
  factory :authentication do
    sequence(:uid)

    factory :google_authentication do
      provider :google_oauth2
    end
    # after
  end
end
