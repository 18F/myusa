FactoryGirl.define do
  factory :notification do
    subject 'Attention'
    body 'It is happening again ...'
    association :user
    association :app, factory: :application
  end
end
