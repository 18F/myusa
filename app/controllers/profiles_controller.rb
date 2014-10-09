
# ProfilesController
class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_profile

  layout 'dashboard'

  def show
    render :edit
  end

  def edit
  end

  def additional
  end

  def update
    if @profile.update(profile_attributes)
      flash[:notice] = t('profile.success')
    else
      flash.now[:error] = t('profile.error')
    end
    redirect_to_target
  end

  def delete_account
    @profile = current_user.profile
    @private_apps = current_user.oauth_applications.private?
    @public_apps = current_user.oauth_applications.public?
  end

  def destroy
    unless params[:email] == current_user.email
      redirect_to delete_account_profile_url, alert: I18n.t('delete_account.invalid_email')
      return
    end

    user = current_user
    sign_out(user)
    user.destroy
    redirect_to root_url, notice: I18n.t('delete_account.deleted_message')
  end

  private

  def redirect_to_target
    redirect_path = profile_path
    if params[:target] == 'additional'
      redirect_path = additional_profile_path
    end
    redirect_to redirect_path
  end

  def assign_profile
    @profile = current_user.profile
  end

  def profile_attributes
    params.require(:profile).permit(:title,
                                    :first_name,
                                    :middle_name,
                                    :last_name,
                                    :suffix,
                                    :address,
                                    :address2,
                                    :city,
                                    :state,
                                    :zip,
                                    :phone_number,
                                    :mobile_number,
                                    :gender,
                                    :marital_status,
                                    :is_parent,
                                    :is_veteran,
                                    :is_student,
                                    :is_retired)
  end
end
