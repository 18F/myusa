class RedesignController < ApplicationController
  def index
    render 'redesign/index', layout: 'redesign'
  end

  # def permissions
  #   require 'ostruct'
  #   @pre_auth = OpenStruct.new
  #   @pre_auth.client = OpenStruct.new
  #   @pre_auth.client.application = OpenStruct.new
  #   @pre_auth.client.application.name = "Sample Application"
  #   @pre_auth.client.uid = "123456789"
  #   @pre_auth.redirect_uri = "https://fake_redirect_uri"
  #   @pre_auth.state = "fake_state"
  #   @pre_auth.response_type = "fake_response_type"
  #   @pre_auth.scope = "fake_scope"
  #   @pre_auth.scopes = "profile.first_name profile.last_name"
  #   @pre_auth.client.application.tos_link = "https://github.com/18F"
  #   @pre_auth.client.application.privacy_policy_link = "https://github.com/18F"
  #   render 'doorkeeper/authorizations/new'
  # end
end
