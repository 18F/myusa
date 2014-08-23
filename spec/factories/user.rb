FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "user_#{n}@gsa.gov" }
    # email 'testy.mctesterson@gsa.gov'
    #
    # factory :owner do
    #   sequence(:email) {|n| 'owner@gsa.gov' }
    #
    #   generate :email
    # end
  end
end
