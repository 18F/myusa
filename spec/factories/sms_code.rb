FactoryGirl.define do
  factory :sms_code do
  	association :user
  	mobile_number { Faker::PhoneNumber.cell_phone }
  	token { Faker::Bitcoin.address }
  	confirmation_sent_at { 1.hour.ago }
  	confirmed_at { Time.now }
  end
 end

