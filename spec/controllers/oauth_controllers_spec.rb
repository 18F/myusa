# require 'rails_helper'
#
# describe OauthController do
#
#   let(:user) { create_confirmed_user_with_profile(email: 'first@user.org') }
#   let(:redirect_uri) { 'http://localhost/' }
#   let(:oauth_scopes) do
#     OauthScope.top_level_scopes + [
#       OauthScope.where('scope_name = "profile.email"').first,
#       OauthScope.where('scope_name = "profile.email"').first
#     ]
#   end
#   let(:app1) do
#     App.create do |a|
#       a.name = 'App1'
#       a.custom_text = 'Custom text for test'
#       a.redirect_uri = redirect_uri
#       a.url = "http://app1host.com"
#       a.is_public = true
#       a.oauth_scopes << oauth_scopes
#
#     end
#   end
#
#   describe "GET #authorize" do
#     before do
#       @app1_client_auth = app1.oauth2_client
#       sign_in(user)
#     end
#
#     context 'with valid scopes and redirect uri' do
#       it "renders a template" do
#       	get :authorize,
#           response_type: 'code',
#           formats: 'html',
#           scope: 'profile.email',
#           client_id: @app1_client_auth.client_id,
#           redirect_uri: redirect_uri
#
#         expect(response).to render_template(:authorize)
#       end
#     end
#
#     context 'with invalid scope' do
#       it "renders a template" do
#         get :authorize,
#           response_type: 'code',
#           formats: 'html',
#           scope: 'profile.last_name',
#           client_id: @app1_client_auth.client_id,
#           redirect_uri: redirect_uri
#
#         expect(response).to redirect_to(controller.get_redirect_uri(redirect_uri))
#       end
#     end
#
#
#   end # end GET #show
#
#   describe "POST #allow" do
#
#   end
#
# end
