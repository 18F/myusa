class MobileRecoveriesController < ApplicationController
  layout 'login'

  before_filter :authenticate_user!

  def new
    @user = User.new
  end

  def create
    if user_params.has_key?(:unconfirmed_mobile_number) && current_user.update_attributes(user_params)
      current_user.create_sms_code!(mobile_number: current_user.unconfirmed_mobile_number)
      redirect_to users_factors_sms_path
    else
      @user = current_user
      render :new
    end
  end

  def cancel
    render text: t(:skip_this_step, scope: [:mobile_confirmation], profile_link: profile_path).html_safe,
           layout: 'welcome'
  end

  def welcome
    render text: t(:successfully_added, scope: [:mobile_confirmation]),
           layout: 'welcome'
  end

  def resource
    @user
  end
  helper_method :resource

  private

  def user_params
    params.require(:user).permit(:unconfirmed_mobile_number)
  end

end
