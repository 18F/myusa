class Authentication < ActiveRecord::Base
  belongs_to :user
  audit_on :create
end
