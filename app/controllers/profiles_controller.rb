
# ProfilesController
class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  before_filter :assign_profile

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

  private

  def assign_profile
    @profile = @user.profile
  end

  def assign_user
    @user = current_user
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
