class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController
  before_filter :authenticate_resource_owner!, except: [:cancel]

  def create
    params[:scope] = params[:scope].join(' ')
    super
  end

  def cancel
    client_id = (session[:user_return_to] || '').
      match(/[\?&;]client_id=([^&;]+)/).try(:[], 1)
    app = Doorkeeper::Application.find_by_uid(client_id)
    session[:user_return_to] = nil
    url = app.try(:url)
    if url
      redirect_to url
    else
      redirect_to root_url, notice: 'App URL not defined.  Could not return to app.'
    end
  end
end
