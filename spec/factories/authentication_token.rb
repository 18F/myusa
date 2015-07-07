FactoryGirl.define do
  factory :authentication_token, class: AuthenticationToken do
    association :user, factory: :user
  end
end
