class UsersController < Devise::RegistrationsController

  before_filter :authenticate_user!

  def update
    if !current_user.update(user_attributes)
      flash.now[:error] = current_user.errors.full_messages.join("\n")
    end
    redirect_to_target
  end

  private

  def redirect_to_target
    redirect_to settings_account_settings_path
  end

  def user_attributes
    params.require(:user).permit(:two_factor_required)
  end
end
