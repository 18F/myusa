class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController
  def create
    params[:scope] = params[:scope].join(" ")
    super
  end


  def pre_auth
    @pre_auth ||= Doorkeeper::OAuth::PreAuthorization.new(Doorkeeper.configuration, server.client_via_uid, current_user, params)
  end

end
