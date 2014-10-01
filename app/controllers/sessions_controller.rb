class SessionsController < Devise::SessionsController
  include Devise::Controllers::Rememberable
  before_filter :set_logout_user, only: [:destroy]

  layout 'login', only: [:new]
  before_action :authenticate_user_from_token!, only: [:new]

  before_filter :clear_return_to, only: [:new], unless: -> { params[:login_required].present? }

  def create
    @email = params[:user][:email]
    user = User.find_by_email(@email) ||
           User.create!(email: @email)

    @token = user.set_authentication_token(
      return_to: stored_location_for(:user),
      remember_me: (params[:user][:remember_me] == '1')
    )
  end

  def show
    old_token = AuthenticationToken.find(params[:token_id])
    user = old_token.user

    @token = user.set_authentication_token(
      return_to: old_token.return_to,
      remember_me: old_token.remember_me
    )

    flash.now[:notice] = I18n.t(:resent_token)
    render :create
  rescue ActiveRecord::RecordNotFound => e
    redirect_to new_user_session_url, notice: I18n.t(:no_user_token)
  end

  private

  def authenticate_user_from_token!
    if warden.authenticate(:email_authenticatable)
      redirect_to after_sign_in_path_for(current_user)
    end
  end

  def set_logout_user
    @logged_out_user = current_user
  end
end
