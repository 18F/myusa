class Api::V1::ProfilesController < Api::ApiController
  doorkeeper_for :show, :scopes => Profile.scopes

  def show
    scope_list = current_scopes
    filtered_profile = current_resource_owner.profile.filtered_profile(scope_list)
    if params[:schema].present?
      render :json => filtered_profile.to_schema_dot_org_hash(scope_list)
    else
      # Limit profile attributes to just those chosen by app owner during app registration.
      render json: filtered_profile.as_json(:scope_list => scope_list).merge("uid" => current_resource_owner.uid, "id" => current_resource_owner.uid)
    end
  end
end
