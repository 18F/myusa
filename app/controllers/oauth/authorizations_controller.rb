class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController
  before_filter :authenticate_resource_owner!, except: [:cancel]

  def create
    params[:scope] = params[:scope].join(' ')
    super
  end

  def cancel
    session[:user_return_to] = nil
    url = params[:app_uri]
    if url
      redirect_to url
    else
      redirect_to root_url, notice: 'App URL not defined.  Could not return to app.'
    end
  end
end
