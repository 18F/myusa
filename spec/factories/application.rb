FactoryGirl.define do
  factory :application, class: Doorkeeper::Application do
    name 'Client App'
    # Redirect to the 'native_uri' so that Doorkeeper redirects us back to a token page in our app.
    redirect_uri 'urn:ietf:wg:oauth:2.0:oob'
    scopes 'profile.email profile.title profile.first_name profile.middle_name ' \
    'profile.last_name profile.phone_number profile.suffix profile.address ' \
    'profile.address2 profile.zip profile.gender profile.marital_status ' \
    'profile.is_parent profile.is_student profile.is_veteran profile.is_retired'
    association :owner, factory: :user
    public true
  end
end
