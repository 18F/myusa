class SessionsController < Devise::SessionsController

  before_action :authenticate_user_from_token!, only: [:new]

  def create
    user = User.find_by_email(params[:user][:email]) ||
           User.create!(email: params[:user][:email])

    user.set_authentication_token

    # TODO: template with instructions for completing token authentication.
    render text: "CYM, #{user.email}"
  end

  private

  def authenticate_user_from_token!
    user_email = params[:email].presence
    user = user_email && User.find_by_email(user_email)

    return unless user && user.authentication_token

    if user.authentication_sent_at &&
       user.authentication_sent_at < 30.minutes.ago
      # TODO: l10n
      flash[:alert] = 'token expired'
    elsif user.verify_authentication_token(params[:token])
      user.expire_authentication_token
      sign_in_and_redirect user
    else
      logger.warn "Invalid token #{user.authentication_token} from user " +
                  user.uid
    end
  end
end
