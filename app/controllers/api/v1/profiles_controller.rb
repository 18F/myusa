class Api::V1::ProfilesController < Api::ApiController
  # before_filter :oauthorize_scope

  doorkeeper_for :show , :scopes => [
    'profile', 'profile.email', 'profile.first_name', 'profile.last_name'
  ]

  def show
    scope_list = doorkeeper_token.scopes.to_a # ['profile.email'] # @token.authorization.scope.split(" ")
    filtered_profile = current_resource_owner.profile.filtered_profile(scope_list)
    if params[:schema].present?
      render :json => filtered_profile.to_schema_dot_org_hash(scope_list)
    else
      # Limit profile attributes to just those chosen by app owner during app registration.
      render :json => filtered_profile.as_json(:scope_list => scope_list) #.merge("uid" => @user.uid, "id" => @user.uid)
    end
  end
end
