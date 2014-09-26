FactoryGirl.define do
  factory :application, class: Doorkeeper::Application do
    name 'Client App'
    # Redirect to the 'native_uri' so that Doorkeeper redirects us back to a token page in our app.
    redirect_uri 'urn:ietf:wg:oauth:2.0:oob'
    scopes 'profile.email profile.last_name'
    owners { create_list(:user, 1) }
    public true

    after(:create) {|a| a.owner_emails = a.owners.map(&:email).join(' ') }

    trait :with_developers do
      after(:create) do |application|
        application.developers = create_list(:user, 2)
        application.save!
        application
      end
    end
  end
end
