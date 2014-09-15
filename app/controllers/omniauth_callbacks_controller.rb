class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    # TODO: L10N of fglash notices
    if user = User.find_from_omniauth(request.env['omniauth.auth'])
      sign_in_and_redirect user
    elsif user = User.create_from_omniauth(request.env['omniauth.auth'])
      sign_in user
      redirect_to new_mobile_recovery_path
    else
      flash.alert = 'Unable to connect with Google'
      redirect_to new_user_session_path
    end
  end
end
