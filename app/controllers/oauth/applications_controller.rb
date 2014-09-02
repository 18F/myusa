class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  before_filter :authenticate_user!
  layout "application"
  
  def index
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
      "<div class='col-md-3'> Consumer Secret Key  </div><div class='col-md-3'> #{@application.secret} </div>"\
      "</div>".html_safe

      redirect_to oauth_applications_path
    else
      render :new
    end
  end

  private

  def application_params
    app_params = params.require(:application).permit(:name, :description, :short_description, :custom_text, :url, :image, :scopes, :redirect_uri)
    app_params[:scopes] = params[:scope] ? params[:scope].join(' ') : []
    app_params
  end
end
