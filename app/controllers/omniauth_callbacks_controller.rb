class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    20.times do Rails.logger.debug('auth') end
      Rails.logger.debug(request.env["omniauth.auth"])
    user = User.find_from_omniauth(request.env["omniauth.auth"])
    if user
      flash.notice = "Signed in Through Google!"
      sign_in_and_redirect user
    else
      user = User.create({:email => request.env["omniauth.auth"].info.email, :first_name => request.env["omniauth.auth"].info.first_name})
      session["devise.user_attributes"] = request.env["omniauth.auth"].attributes
      # flash.notice = "You are almost Done! Please provide a password to finish setting up your account"
      flash.notice = "Welcome new user. Please complete your profile."
      sign_in(user)
      sign_in_and_redirect user
    end
  end
end