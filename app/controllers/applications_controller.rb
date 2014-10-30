class ApplicationsController < Doorkeeper::ApplicationsController
  before_filter :authenticate_user!

  before_filter :build_application, only: [:new, :create]
  
  # this is set in the parent for typical resource routes, but we need to add :new_api_key and :make_public
  before_filter :set_application, only: [:show, :edit, :update, :destroy, :new_api_key, :make_public]
  before_filter :update_application, only: [:create, :update]

  before_filter :require_owner_or_admin!, only: [:show, :edit, :update, :destroy, :new_api_key, :make_public]

  layout 'dashboard'

  def new; end

  def create
    if @application.errors.empty? && @application.save
      current_user.grant_role!(:owner, @application)

      message = I18n.t('new_application')
      flash[:notice] = render_to_string partial: 'doorkeeper/applications/flash',
                                        locals: { application: @application, message: message }
      redirect_to authorizations_path
    else
      render :new
    end
  end

  def update
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
    @application.request_public(current_user)
    redirect_to authorizations_path, notice: I18n.t('app_status.requested_public')
  end

  private

  def resource
    @application
  end

  def build_application
    @application = Doorkeeper::Application.new
  end

  def update_application
    @application.attributes = application_params
  end

  def allowed_application_params
    params = [
      :name, :description, :short_description, :custom_text, :url,
      :logo_url, :owner_emails, :developer_emails, :scopes, :redirect_uri
    ]
    if current_user.has_role?(:admin)
      params << :public
    end

    return params
  end

  def application_params
    if params.has_key?(:scope)
      params[:application][:scopes] = params[:scope].join(' ')
    end

    params.require(:application).permit(*allowed_application_params)
  end
end
