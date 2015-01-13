FactoryGirl.define do
  factory :application, class: Doorkeeper::Application do
    ignore do
      owner nil
    end

    name 'Client App'
    # Redirect to the 'native_uri' so that Doorkeeper redirects us back to a token page in our app.
    redirect_uri 'urn:ietf:wg:oauth:2.0:oob'
    scopes 'profile.email profile.last_name'
    public true

    after(:create) do |a, evaluator|
      if evaluator.owner
        evaluator.owner.grant_role!(:owner, a)
      end
    end

    trait :federal_agency do
      organization 'Office of Unspecified Services'
      federal_agency true
      terms_of_service_accepted true
    end

    trait(:private) do
      public false
    end
  end
end
