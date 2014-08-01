class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    # TODO: L10N of fglash notices
    if user = User.find_or_create_from_omniauth(request.env['omniauth.auth'])
      flash.notice = 'Signed in Through Google!'
      sign_in_and_redirect user
    else
      flash.alert = 'Unable to connect with Google'
      redirect_to new_user_session_path
    end
  end
end
