class SessionsController < Devise::SessionsController
  include Devise::Controllers::Rememberable

  before_action :authenticate_user_from_token!, only: [:new]

  def create
    user = User.find_by_email(params[:user][:email]) ||
           User.create!(email: params[:user][:email])

    user.set_authentication_token(
      return_to: stored_location_for(:user),
      remember_me: (params[:user][:remember_me] == '1')
    )

    # TODO: template with instructions for completing token authentication.
    render text: "CYM, #{user.email}"
  end

  private

  def authenticate_user_from_token!
    if warden.authenticate(:email_authenticatable)
      redirect_to after_sign_in_path_for(current_user)
    end
  end
end
