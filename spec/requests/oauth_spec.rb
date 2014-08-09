require 'spec_helper'

describe "OAuth" do
  #
  #
  # let(:user) do
  #   User.create do |u|
  #     u.email = 'testy.mctesterson@gsa.gov'
  #   end
  # end
  #
  # let(:client_app) do
  #   Doorkeeper::Application.create do |a|
  #     a.name = 'Client App'
  #     a.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
  #     # a.redirect_uri = 'http://www.example.com/auth/myusa/callback'
  #   end
  # end
  #
  # let(:oauth_client) do
  #   OAuth2::Client.new(client_app.uid, client_app.secret, site: 'http://www.example.com') do |b|
  #     b.request :url_encoded
  #     b.adapter :rack, Rails.application
  #   end
  # end
  #
  # before :each do
  #   login_as user
  # end
  #
  # scenario 'auth ok' do
  #   response = post oauth_client.auth_code.authorize_url(
  #     redirect_uri: client_app.redirect_uri,
  #     scope: ['profile.email'],
  #     state: 'state'
  #   )
  #
  #   # pp response
  #   puts response.location
  #   pp get(response.location)
  #
  #   # code = get_code_from_redirect(response.location)
  #
  #   # token = oauth_client.auth_code.get_token(code, redirect_uri: client_app.redirect_uri)
  #   # expect(token).to_not be_expired
  # end

end
