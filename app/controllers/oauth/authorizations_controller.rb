class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController
  def create
    params[:scope] = params[:scope].join(" ")
    super
  end
end
