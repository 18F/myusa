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
    user = params[:email].present? && User.find_by_email(params[:email])
    token = user.present? && AuthenticationToken.find_by_user_id(user.id)

    return unless user && token

    token.raw = params[:token]
    if token.valid?
      token.delete

      if token.remember_me
        remember_me user
      end

      sign_in :user, user
      redirect_to token.return_to || after_sign_in_path_for(user)

    else
      logger.warn "Invalid token #{user.authentication_token} from user #{user.uid}"
    end
  end
end
