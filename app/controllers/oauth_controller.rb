class OauthController < ApplicationController
  before_filter :set_client_app, :only => [:authorize, :allow]
  before_filter :set_client_credentials_handler, :only => [:authorize]
  
  after_filter ({ :only => :authorize }) do |controller|
    # TODO migrate app authorization log table
    # controller.log_app_authorization(controller)    
  end

  def authorize 
    @oauth2 = Songkick::OAuth2::Provider.parse(current_user, request.env)
    unless scopes_allowed?
      redirect_to get_redirect_uri(@oauth2.client.owner.redirect_uri)
      return
    end

    if @oauth2.client.owner.sandbox? && !current_user.nil? && (current_user != @oauth2.client.owner.user)  # Check that user is not nil and is sandbox app owner.
      redirect_to unknown_app_path
      return
    end

    if @oauth2.redirect?
      redirect_to @oauth2.redirect_uri, :status => @oauth2.response_status
    else
      headers.merge!(@oauth2.response_headers)
      if @oauth2.response_body
        render :text => @oauth2.response_body, :status => @oauth2.response_status
      else
        session[:user_return_to] = request.original_fullpath if authenticate_user!
      end
    end
  end
  
  def allow
    selected_scopes = params[:selected_scopes].select { |k, v|
      v == "1"
    }.keys.join(' ')
    new_params = params.dup
    new_params[:scopes] = selected_scopes
    @auth = Songkick::OAuth2::Provider::Authorization.new(current_user, new_params)
    if params[:allow] == '1' and params[:commit] == 'Allow' && pass_sandbox_check(params)
      @auth.grant_access!
    else
      @auth.deny_access!
    end
    current_user.set_values_from_scopes(params[:new_profile_values])
    redirect_to @auth.redirect_uri, :status => @auth.response_status
  end

  def deauthorize
    current_user.deauthorize_app(@app)
  end

  def pass_sandbox_check params
    pass = false
    if @app.sandbox?
      pass = @app.user == current_user ? true : false
    else
      pass = true
    end
    return pass
  end

  def unknown_app
  end

  protected

  def get_redirect_uri(redirect_uri)
    url_obj           = URI.parse(redirect_uri)
    uri               = Addressable::URI.new # For converting hash to querystring
    uri.query_values  = CGI::parse(url_obj.query || "").merge({error: "access_denied", error_description: t('unauthorized_scope')})
    url_obj.query     = uri.query
    url_obj.to_s
  end
  
  def scopes_allowed?
    @oauth2.scopes.all?{|e| @oauth2.client.owner.oauth_scopes.map(&:scope_name).member?(e)}
  end

  def set_client_app
    begin
      @oauth2_client =  Songkick::OAuth2::Model::Client.find_by_client_id(params[:client_id])
      if params[:grant_type] != 'client_credentials'
        @app = App.find(@oauth2_client.oauth2_client_owner_id)
        session[:auto_approve_account]=true if @app.is_public?
      end
    rescue NoMethodError
      redirect_to unknown_app_path
    end
  end
  
  def set_client_credentials_handler
    Songkick::OAuth2::Provider.handle_client_credentials do |client, owner, scopes|
      owner.user.grant_access!(client, :scopes => ['verify_credentials'])
    end
  end

  def log_app_authorization(controller)
    AppActivityLog.create!(:app => @app, :controller => controller.controller_name, :action => controller.action_name, :user => current_user)
  end
end