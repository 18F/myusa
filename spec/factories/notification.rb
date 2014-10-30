FactoryGirl.define do
  factory :notification do
    subject 'Attention'
    body 'It is happening again ...'
    association :authorization
  end
end
