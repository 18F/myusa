class MobileRecoveriesController < ApplicationController
  layout 'login'

  before_filter :authenticate_user!

  def new; end
  def cancel; end

  def create
    if profile.update_attributes(profile_params)
      profile.create_mobile_confirmation
    else
      flash[:error] = profile.errors.full_messages.join("\n")
      render :new
    end
  end

  def update
    # TODO: clean this up ... gating on the params[:commit] is super fragile.
    if params[:commit] == 'Submit'
      raw_token = mobile_confirmation_params[:raw_token]
      if raw_token && mobile_confirmation && mobile_confirmation.authenticate(raw_token)
        # redirect_to root_path #TODO: fixme
      else
        flash[:error] = 'Please check the number blah blah blah'
        render :create
      end
    elsif params[:commit] == 'Resend Code'
      mobile_confirmation.regenerate_token
      render :update
    end
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
