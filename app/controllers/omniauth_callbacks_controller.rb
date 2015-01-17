class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env['omniauth.auth']

    if user = User.find_or_create_from_omniauth(auth)
      log_success(user)
      sign_in_and_redirect user
    else
      log_failure(user)
      flash.alert = 'Unable to connect with Google'
      redirect_to new_user_session_path
    end
  end

  def failure
    log_failure
    super
  end

  private

  def provider
    return request.env['omniauth.strategy'].name
  end

  def log_success(user)
    UserAction.successful_authentication.create(user: user, data: { authentication_method: provider })
  end

  def log_failure(user=nil)
    UserAction.failed_authentication.create(data: { authentication_method: provider })
  end
end
