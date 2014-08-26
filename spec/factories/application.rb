FactoryGirl.define do
  factory :application, class: Doorkeeper::Application do
    name 'Client App'
    # Redirect to the 'native_uri' so that Doorkeeper redirects us back to a token page in our app.
    redirect_uri 'urn:ietf:wg:oauth:2.0:oob'
    scopes 'profile.email profile.last_name profile.address profile.address2'
    association :owner, factory: :user
    public true
  end
end
