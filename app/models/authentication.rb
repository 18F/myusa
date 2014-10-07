class Authentication < ActiveRecord::Base
  belongs_to :user
  audit_on :after_create
end
