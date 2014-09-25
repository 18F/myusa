class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_filter :clear_return_to, unless: -> { omniauth_params['login_required'].present? }

  def google_oauth2
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

  private

  def omniauth_params
    request.env['omniauth.params']
  end
end
