class ApplicationsController < Doorkeeper::ApplicationsController
  before_filter :authenticate_user!

  # this is set in the parent for typical resource routes, but we need to add :new_api_key and :make_public
  before_filter :set_application, only: [:show, :edit, :update, :destroy, :new_api_key, :make_public]

  before_filter :require_owner_or_admin!, only: [:show, :edit, :update, :destroy, :new_api_key, :make_public]

  layout 'dashboard'

  def new
    @application = Doorkeeper::Application.new
  end

  def create
    @application = Doorkeeper::Application.new(application_params)

    # TODO: just use the acl9 role
    @application.owner = current_user
    current_user.has_role!(:owner, @application)

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
    @application.attributes = application_params

    if @application.errors.empty? && @application.save
      flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :update])
      redirect_to authorizations_path
    else
      render :edit
    end
  end

  # TODO: roll this into update
  def new_api_key
    @application = Doorkeeper::Application.find(params[:id])
    @application.secret = Doorkeeper::OAuth::Helpers::UniqueToken.generate
    @application.save
    message = I18n.t('new_api_key')
    flash[:notice] = render_to_string partial: 'doorkeeper/applications/flash',
                                      locals: { message: message }
    redirect_to authorizations_path
  end

  # TODO: roll this into update
  def make_public
    @application = Doorkeeper::Application.find(params[:id])
    @application.requested_public_at = DateTime.now
    @application.save
    SystemMailer.app_public_email(@application, current_user).deliver
    redirect_to authorizations_path, notice: I18n.t('app_status.requested_public')
  end

  private

  def resource
    @application
  end

  def validate_owner_emails
    return unless application_params.has_key?(:owner_emails)
    if !application_params[:owner_emails].split(' ').include?(current_user.email)
      @application.errors.add(:owner_emails, 'cannot remove self from owners list')
    end
  end

  def application_params
    if params.has_key?(:scope)
      params[:application][:scopes] = params[:scope].join(' ')
    end

    params.require(:application).permit(
      :name, :description, :short_description, :custom_text, :url, :logo_url,
      :owner_emails, :developer_emails, :scopes, :redirect_uri
    )
  end
end
