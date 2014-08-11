class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController
  def create
    if params.has_key?(:profile)
      current_user.profile.update_attributes(profile_params)
    end
    if params[:scope].is_a?(Array)
      params[:scope] = params[:scope].join(" ")
    end
    super
  end

  private

  def profile_params
    params.require(:profile).permit(Profile::FIELDS + Profile::METHODS)
  end
end
