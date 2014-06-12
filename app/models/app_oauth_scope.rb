class AppOauthScope < ActiveRecord::Base
  belongs_to :app
  belongs_to :oauth_scope
#  attr_accessible :oauth_scope_id, :as => [:default, :admin]
#  attr_accessible :app_id, :as => :admin
end
