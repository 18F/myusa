FactoryGirl.define do
  factory :access_grant, class: Doorkeeper::AccessGrant do
    association :resource_owner, factory: :user
    application
    expires_in 2.hours
    scopes 'profile.email profile.city'
  end
end
