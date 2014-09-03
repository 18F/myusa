class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  before_filter :authenticate_user!
  layout "application"

  include ScopeGroups

  def index
    @authorizations = Doorkeeper::AccessToken.where(
      resource_owner_id: current_user.id, revoked_at: nil)
    super
  end

  def create
    @application = Doorkeeper::Application.new(application_params)
    @application.owner = current_user
    if @application.save
      flash[:notice] = I18n.t(:notice, :scope => [:doorkeeper, :flash, :applications, :create])
      respond_with [:oauth, @application]
    else
      render :new
    end
  end

  private

  def application_params
    params.require(:application).permit(:name, :description, :image, :scopes, :redirect_uri)
  end

end
