class MobileRecoveriesController < ApplicationController
  layout 'login'

  before_filter :authenticate_user!

  def new; end
  def cancel
    render text: t(:skip_this_step, scope: [:mobile_confirmation], profile_link: profile_path).html_safe,
           layout: 'welcome'
  end

  def create
    if profile.update_attributes(profile_params)
      profile.create_mobile_confirmation
    else
      flash[:error] = profile.errors.full_messages.join("\n")
      render :new
    end
  end

  def update
    raw_token = mobile_confirmation_params[:raw_token]
    if raw_token && mobile_confirmation && mobile_confirmation.authenticate(raw_token)
      render text: t(:successfully_added, scope: [:mobile_confirmation]),
             layout: 'welcome'
    else
      flash[:error] = t(:bad_token, scope: [:mobile_confirmation],
                                    resend_link: mobile_recovery_resend_path,
                                    reenter_link: new_mobile_recovery_path).html_safe
      render :create
    end

  end

  def resend
    mobile_confirmation.regenerate_token
    render :update
  end

  private

  def profile
    current_user.profile
  end

  def mobile_confirmation
    profile.mobile_confirmation
  end

  def profile_params
    params.require(:profile).permit(:mobile_number)
  end

  def mobile_confirmation_params
    params.require(:mobile_confirmation).permit(:raw_token)
  end

end
