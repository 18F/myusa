class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env['omniauth.auth']

    if user = User.find_from_omniauth(auth)
      sign_in_and_redirect user, omniauth: true
    elsif user = User.create_from_omniauth(auth)
      sign_in user, omniauth: true
      redirect_to new_mobile_recovery_path
    else
      flash.alert = 'Unable to connect with Google'
      redirect_to new_user_session_path
    end
  end
end
