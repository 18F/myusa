class Api::ApiController < ActionController::Base
  protect_from_forgery with: :null_session
  skip_before_filter :verify_authenticity_token

  doorkeeper_for :all

  # protected

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
  alias_method :current_user, :current_resource_owner

  def current_scopes
    doorkeeper_token.scopes.to_a
  end

  def doorkeeper_unauthorized_render_options
    {json: {message: 'Not Authorized'}}
  end

  def doorkeeper_forbidden_render_options
    {json: {message: 'Forbidden'}}
  end

end
