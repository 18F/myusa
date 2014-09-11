
# ProfilesController
class ProfilesController < ApplicationController
  before_filter :authenticate_user!, except: [:resend_token]
  before_filter :assign_profile, except: [:resend_token]

  layout 'dashboard'

  def show
  end

  def edit
  end

  def update
    if @profile.update(profile_attributes)
      redirect_to profile_path, notice: 'Your profile was sucessfully updated.'
    else
      flash.now[:error] = 'Something went wrong.'
      render :edit
    end
  end

  def resend_token
    @email = params[:email]
    user = User.where(email: @email).first
    if user.blank?
      redirect_to new_user_session_url, notice: I18n.t(:no_user_token)
      return
    end
    user.set_authentication_token
    flash.now[:notice] = I18n.t(:resent_token)
    render 'devise/sessions/create'
  end

  def delete_account
    @profile = current_user.profile
    @private_apps = current_user.private_applications
    @public_apps = current_user.public_applications
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
