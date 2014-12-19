FactoryGirl.define do
  factory :access_token, class: Doorkeeper::AccessToken do
    association :resource_owner, factory: :user
    application
    expires_in Doorkeeper.configuration.access_token_expires_in
    scopes 'profile.email profile.city'
  end
end
