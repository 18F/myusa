class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    if user = User.find_from_omniauth(request.env["omniauth.auth"])
      flash.notice = "Signed in Through Google!"
      sign_in_and_redirect user
    else
      # session["devise.user_attributes"] = user.attributes
      # flash.notice = "You are almost Done! Please provide a password to finish setting up your account"
      redirect_to new_user_session_path
    end
  end
end
