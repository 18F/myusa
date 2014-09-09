class User::RecoveriesController < ApplicationController
  layout 'login'

  before_filter :authenticate_user!

  def new; end

  def create
    if profile.update_attributes(profile_params)
      profile.profile_confirmations.create(profile_field: 'mobile_number')
    else
      flash[:error] = profile.errors.full_messages.join("\n")
      render :new #, flash: { error: e.message }
    end
  end

  def update
    raw_token = profile_confirmation_params[:raw_token]
    if raw_token && profile_confirmation.authenticate(raw_token)
      redirect_to root_path #TODO: fixme
    else
      flash[:error] = 'Please check the number blah blah blah'
      render :create
    end
  end

  def profile
    current_user.profile
  end

  def profile_confirmation
    profile.profile_confirmations.find_by_profile_field('mobile_number')
  end

  def profile_params
    params.require(:profile).permit(:mobile_number)
  end

  def profile_confirmation_params
    params.require(:profile_confirmation).permit(:raw_token)
  end

end
