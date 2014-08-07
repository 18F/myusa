class Api::ApiController < ApplicationController
  protect_from_forgery with: :null_session

  skip_before_filter :verify_authenticity_token
  after_filter {|controller| log_activity(controller)}

  doorkeeper_for :all

  protected

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def doorkeeper_unauthorized_render_options
    {json: {message: 'Not Authorized'}}
  end

  def doorkeeper_forbidden_render_options
    {json: {message: 'Forbidden'}}
  end

  def log_activity(controller)
#    AppActivityLog.create!(:app => @app, :controller => controller.controller_name, :action => controller.action_name, :user => @user)
  end
end
