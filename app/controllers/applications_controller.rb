class ApplicationsController < Doorkeeper::ApplicationsController
  before_filter :authenticate_user!
  layout 'dashboard'

  def create
    @application = Doorkeeper::Application.new(application_params)
    @application.owners << current_user
    if @application.save
      message = I18n.t('new_application')
      flash[:notice] = render_to_string partial: 'doorkeeper/applications/flash',
                                        locals: { application: @application, message: message }
      redirect_to authorizations_path
    else
      render :new
    end
  end

  def update
    if @application.update_attributes(application_params)
      flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :update])
      redirect_to authorizations_path
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
    redirect_to authorizations_path
  end

  def make_public
    @application = Doorkeeper::Application.find(params[:id])
    @application.requested_public_at = DateTime.now
    @application.save
    ApplicationPublicMailer.notify_is_public(@application, current_user).deliver
    redirect_to authorizations_path, notice: I18n.t('app_status.requested_public')
  end

  private

  def application_params
    app_params = params.require(:application).permit(:name, :description, :short_description, :custom_text, :url, :image, :scopes, :redirect_uri)
    app_params[:scopes] = params[:scope] ? params[:scope].join(' ') : []
    app_params
  end
end
