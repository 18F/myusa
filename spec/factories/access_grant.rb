FactoryGirl.define do
  factory :access_grant, class: Doorkeeper::AccessGrant do
    association :resource_owner, factory: :user
    application
    expires_in 2.hours
    redirect_uri { Faker::Internet.url }
    scopes 'profile.email profile.last_name'
  end
end
