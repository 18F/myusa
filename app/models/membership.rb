class Membership < ActiveRecord::Base
  belongs_to :oauth_application,  class_name: Doorkeeper::Application
  belongs_to :user
end
