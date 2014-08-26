class SessionsController < Devise::SessionsController
  include Devise::Controllers::Rememberable

  layout "login", only: [:new]
  before_action :authenticate_user_from_token!, only: [:new]

  def create
    @email = params[:user][:email]
    user = User.find_by_email(@email) ||
           User.create!(email: @email)
    user.set_authentication_token(
      return_to: stored_location_for(:user),
      remember_me: (params[:user][:remember_me] == '1')
    )
  end

  private

  def authenticate_user_from_token!
    if warden.authenticate(:email_authenticatable)
      redirect_to after_sign_in_path_for(current_user)
    end
  end

end
