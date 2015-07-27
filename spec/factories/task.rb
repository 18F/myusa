FactoryGirl.define do
  factory :task do
    name "Fix the thing"
    association :user
    app_id 1
  end
end
