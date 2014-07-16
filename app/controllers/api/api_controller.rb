class Api::ApiController < ApplicationController
  protect_from_forgery with: :exception

  skip_before_filter :verify_authenticity_token
  before_filter :oauthorize
  after_filter {|controller| log_activity(controller)}

  protected

  def oauthorize
    token_string = Songkick::OAuth2::Router.access_token_from_request(request)
    authorization = Songkick::OAuth2::Model.find_access_token(token_string)
    user = authorization && authorization.owner
    @token = Songkick::OAuth2::Provider::AccessToken.new(user,
                                                         authorization && authorization.scopes.to_a,
                                                         token_string)

    if @token.valid?
      @user = authorization.owner
      @app = authorization.client.owner
    end
  end

  def validate_oauth(oauth_scopes)
    unless @token.valid?
      render :json => {:message => "Invalid token"}, :status => @token.response_status
      return false
    end

    auth = @token.authorization
    scope_list = auth && auth.scope

    oauth_scopes.each do |oauth_scope|
      return true if scope_in_scope_list?(oauth_scope, scope_list)
    end

    render :json => {:message => no_scope_message}, :status => 403
    return false
  end

  def scope_in_scope_list?(oauth_scope, scope_list)
    return true if (scope_list || "").split(" ").member?(oauth_scope.scope_name)
    return false
  end

  def log_activity(controller)
#    AppActivityLog.create!(:app => @app, :controller => controller.controller_name, :action => controller.action_name, :user => @user)
  end
end
