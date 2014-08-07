class OauthController < ApplicationController
  before_filter :set_client_app, :only => [:authorize, :allow]
  before_filter :set_client_credentials_handler, :only => [:authorize]

  # after_filter ({ :only => :authorize }) do |controller|
  #   # TODO migrate app authorization log table
  #   # controller.log_app_authorization(controller)
  # end

  def authorize
    @oauth2 = Songkick::OAuth2::Provider.parse(current_user, request.env)
    unless scopes_allowed?
      redirect_to get_redirect_uri(@oauth2.client.owner.redirect_uri)
      return
    end

    if @oauth2.client.owner.sandbox? && !current_user.nil? &&
        (current_user != @oauth2.client.owner.user)
      redirect_to unknown_app_path
      return
    end

    if @oauth2.redirect?
      redirect_to @oauth2.redirect_uri, status: @oauth2.response_status
    else
      headers.merge!(@oauth2.response_headers)
      is_exchange = (@oauth2.class == Songkick::OAuth2::Provider::Exchange)
      if is_exchange ? @oauth2.response_body : !@oauth2.valid?
        render text: (is_exchange ? @oauth2.response_body : ''),
               status: @oauth2.response_status
      else
        # TODO: What if user isn't authenticated? -- yoz
        session[:user_return_to] = request.original_fullpath if authenticate_user!
      end
    end
  end

  def allow
    @auth = create_authorization_from_params(params)
    if params[:allow] == '1' && params[:commit] == 'Allow' && pass_sandbox_check
      @auth.grant_access!
    else
      @auth.deny_access!
    end
    current_user.set_values_from_scopes(params[:new_profile_values]) unless params[:new_profile_values].blank?
    redirect_to @auth.redirect_uri, status: @auth.response_status
  end

  def deauthorize
    current_user.deauthorize_app(@app)
  end

  def unknown_app
  end

  def cancel
    app = App.find_by_return_to_url(session[:user_return_to])
    session[:user_return_to] = nil
    redirect_to app.try(:url) || root_url
  end

  protected

  def create_authorization_from_params(params)
    selected_scopes = (params[:selected_scopes] || {}).select do |_, v|
      v == '1'
    end.keys.join(' ')
    new_params = params.dup
    new_params[:scope] = selected_scopes
    Songkick::OAuth2::Provider::Authorization.new(current_user, new_params)
  end

  def pass_sandbox_check
    !@app.sandbox? || @app.user == current_user
  end

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

  # def log_app_authorization(controller)
  #   AppActivityLog.create!(:app => @app, :controller => controller.controller_name, :action => controller.action_name, :user => current_user)
  # end
end
