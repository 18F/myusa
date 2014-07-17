class SessionsController < Devise::SessionsController

  before_action :authenticate_user_from_token!, only: [:new]

  # def new
  #
  #   super
  # end

  def create
    user = User.find_by_email(params[:user][:email])
    if !user
      user = User.create!(email: params[:user][:email])
    end
    user.set_authentication_token

    #TODO: fixme ...
    render :text => "CYM, #{user.email}"
  end

  private

  def authenticate_user_from_token!
    user_email = params[:email].presence
    user = user_email && User.find_by_email(user_email)

    if user && user.authentication_token
      if user.authentication_sent_at && user.authentication_sent_at < 30.minutes.ago
        #TODO: i18n
        flash[:alert] = 'token expired'
      elsif user && user.verify_authentication_token(params[:token])
        user.expire_authentication_token
        sign_in_and_redirect user
      end
    end
  end
end
