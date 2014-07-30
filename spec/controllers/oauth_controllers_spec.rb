# require 'spec_helper'

# describe OauthController do

#   describe "GET #authorize" do
#     before do
#     	#@controller = OauthController
#       @user = create_confirmed_user_with_profile(email: 'first@user.org')
# 	    @app1 = App.create(name: 'App1', custom_text: 'Custom text for test'){|app| app.redirect_uri = "http://localhost/"; app.url="http://app1host.com"}
# 	    @app1.is_public = true
# 	    @app1.save!
# 	    @app1.oauth_scopes << OauthScope.top_level_scopes
# 	    @app1.oauth_scopes << OauthScope.where('scope_name = "profile.email"').first
# 	    @app1_client_auth = @app1.oauth2_client
#       sign_in(@user)
#     end
    
#     it "updates the notification viewed_at timestamp" do

#     	get :authorize,  response_type: 'code', formats: 'html', scope: 'profile notifications', client_id: @app1_client_auth.client_id, redirect_uri: 'http://localhost/'

#     end    
#   end # end GET #show
  
# end