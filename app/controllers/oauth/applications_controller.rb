class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  before_filter :authenticate_user!

  layout 'application'

  include ScopeGroups

  def index
    super
    @authorizations = Doorkeeper::AccessToken.where(
      resource_owner_id: current_user.id, revoked_at: nil)
    @applications = current_user.oauth_applications
  end

  def new
    super
  end

  def create
    @application = Doorkeeper::Application.new(application_params)
    @application.owner = current_user
    if @application.save

      flash[:notice] = "<h4>Your application has been created. Please save the below information in safe place.</h4><br>"\
      "<div class='row'>"\
      "<div class='col-md-3'> Consumer Public Key  </div><div class='col-md-3'> #{@application.uid} </div>"\
      "</div>"\
      "<div class='row'>"\
      "<div class='col-md-3'> Consumer Secret Key  </div><div class='col-md-3' id='secret-key'> #{@application.secret} </div>"\
      "</div>".html_safe

      redirect_to oauth_applications_path

      # flash[:notice] = I18n.t(
      #   :notice, scope: [:doorkeeper, :flash, :applications, :create])

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

  private

  def application_params
    app_params = params.require(:application).permit(:name, :description, :short_description, :custom_text, :url, :image, :scopes, :redirect_uri)
    app_params[:scopes] = params[:scope] ? params[:scope].join(' ') : []
    app_params
  end
end
