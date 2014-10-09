class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env['omniauth.auth']

    if user = User.find_from_omniauth(auth)
      log_success(user)
      sign_in_and_redirect user
    elsif user = User.create_from_omniauth(auth)
      log_success(user)
      sign_in user
      redirect_to new_mobile_recovery_path
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
    params[:provider]
  end

  def log_success(user)
    UserAction.successful_authentication.create(user: user, data: { authentication_method: provider })
  end

  def log_failure(user=nil)
    UserAction.failed_authentication.create(data: { authentication_method: provider })
  end
end
