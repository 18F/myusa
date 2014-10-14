class MobileRecoveriesController < ApplicationController
  layout 'login'

  before_filter :authenticate_user!

  def new; end

  def create
    if profile.update_attributes(profile_params)
      session[:two_factor_return_to] = mobile_recovery_welcome_path
      redirect_to users_factors_sms_path
    else
      flash[:error] = profile.errors.full_messages.join("\n")
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

  private

  def profile
    current_user.profile
  end

  def profile_params
    params.require(:profile).permit(:mobile_number)
  end

end
