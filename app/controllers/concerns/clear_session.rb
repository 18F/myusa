# ClearSession
module ClearSession
  extend ActiveSupport::Concern

  private

  def clear_return_to
    return if params[:myusa] == 'true'
    session_key = stored_location_key_for(:user)
    session.delete(session_key) if is_navigational_format?
  end
end
