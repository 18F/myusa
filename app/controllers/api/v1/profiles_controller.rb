
# Api::V1::ProfilesController
class Api::V1::ProfilesController < Api::ApiController
  doorkeeper_for :show, scopes: Profile.scopes

  def show
    scope_list = current_scopes
    profile = current_resource_owner.profile
    if params[:openid_connect].present?
      render json: profile.to_openid_connect_hash(scope_list)
    elsif params[:schema].present?
      render json: profile.to_schema_dot_org_hash(scope_list)
    else
      render json: profile.to_oauth_hash(scope_list)
    end
  end
end
