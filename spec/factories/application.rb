FactoryGirl.define do
  factory :application, class: Doorkeeper::Application do
    ignore do
      owner nil
    end

    name 'Client App'
    # Redirect to the 'native_uri' so that Doorkeeper redirects us back to a token page in our app.
    redirect_uri 'urn:ietf:wg:oauth:2.0:oob'
    scopes 'profile.email profile.city'
    public true

    after(:create) do |a, evaluator|
      if evaluator.owner
        evaluator.owner.grant_role!(:owner, a)
      end
    end
  end
end
