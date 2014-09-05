class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  before_filter :authenticate_user!
  # before_filter :application_params, only: [:create, :update]

  layout 'application'

  def index
    super
    @authorizations = Doorkeeper::AccessToken.where(
      resource_owner_id: current_user.id, revoked_at: nil)
    @applications = current_user.oauth_applications
  end

  def create
    @application = Doorkeeper::Application.new(application_params)
    @application.owner = current_user
    if @application.save
      message = I18n.t('new_application')
      flash[:notice] = render_to_string partial: 'doorkeeper/applications/flash', 
                                        locals: { application: @application, message: message }
      redirect_to oauth_applications_path
    else
      render :new
    end
  end

  def update
    if @application.update_attributes(application_params)
      flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :update])
      redirect_to oauth_applications_path
    else
      render :edit
    end
  end

  def new_api_key
    @application = Doorkeeper::Application.find(params[:id])
    @application.secret = Doorkeeper::OAuth::Helpers::UniqueToken.generate
    @application.save
    message = I18n.t('new_api_key')
    flash[:notice] = render_to_string partial: 'doorkeeper/applications/flash',
                                      locals: { message: message }
    redirect_to oauth_applications_path
  end

  private

  def application_params
    params.require(:application).permit(
      :name, :description, :image, :scopes, :redirect_uri)
  end
end
