FactoryGirl.define do
  factory :access_token, class: Doorkeeper::AccessToken do
    association :resource_owner, factory: :user
    application
    expires_in 2.hours
    scopes 'profile.email profile.last_name'
  end
end
