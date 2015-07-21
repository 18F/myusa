FactoryGirl.define do
  factory :task_item do
    name "Task Item 1"
    url "http://gsa.gov"
    association :task
  end
end
