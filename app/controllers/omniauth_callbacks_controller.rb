class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env['omniauth.auth']

    if user = User.find_from_omniauth(auth)
      log_success(user, 'google_oauth2')
      sign_in_and_redirect user
    elsif user = User.create_from_omniauth(auth)
      log_success(user, 'google_oauth2')
      sign_in user
      redirect_to new_mobile_recovery_path
    else
      log_failure(user, 'google_oauth2')
      flash.alert = 'Unable to connect with Google'
      redirect_to new_user_session_path
    end
  end

  def failure
    log_failure(env['omniauth.error.strategy'].name)
    super
  end

  private

  def log_success(user, provider)
    UserAction.successful_authentication.create(user: user, data: { authentication_method: provider })
  end

  def log_failure(provider)
    UserAction.failed_authentication.create(data: { authentication_method: provider })
  end
end
