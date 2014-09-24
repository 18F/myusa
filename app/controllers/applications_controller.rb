class ApplicationsController < Doorkeeper::ApplicationsController
  before_filter :authenticate_user!
  layout 'dashboard'

  def new
    @application = Doorkeeper::Application.new(owner_emails: current_user.email)
  end

  def create
    @application = Doorkeeper::Application.new(application_params)

    if !application_params[:owner_emails].split(' ').include?(current_user.email)
      @application.errors.add(:owner_emails, 'cannot remove self from owners list')
    end

    if @application.errors.empty? && @application.save
      message = I18n.t('new_application')
      flash[:notice] = render_to_string partial: 'doorkeeper/applications/flash',
                                        locals: { application: @application, message: message }
      redirect_to authorizations_path
    else
      render :new
    end
  end

  def update
    if !application_params[:owner_emails].split(' ').include?(current_user.email)
      @application.errors.add(:owner_emails, 'cannot remove self from owners list')
    end

    if @application.errors.empty? && @application.update_attributes(application_params)
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
    redirect_to authorizations_path, notice: I18n.t('app_status.requested_public')
  end

  private

  def application_params
    if params.has_key?(:scope)
      params[:application][:scopes] = params[:scope].join(' ')
    end

    params.require(:application).permit(
      :name, :description, :short_description, :custom_text, :url, :image,
      :owner_emails, :developer_emails, :scopes, :redirect_uri
    )
  end
end
