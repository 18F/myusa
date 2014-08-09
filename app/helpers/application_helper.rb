# ApplicationHelper
module ApplicationHelper
  def standard_flash(msg)
    bootstrap_key_mapping =
    {
      'alert' => 'warning',
      'error' => 'danger',
      'notice' => 'info'
    }
    bootstrap_key_mapping[msg] || msg
  end

  def bs_button_to(text, action, options = {})
    form_tag action do
      button_tag({ type: 'submit' }.merge(options)) do
        text
      end
    end
  end

  def return_to_app_link
    client_id = find_client_id
    app = client_id && Doorkeeper::Application.find_by_uid(client_id)
    return nil if app.nil? || app.url.blank?
    link_to("Return to #{app.name}", cancel_auth_path(app_uri: app.url), class: 'back-to-app')
  end

  private

  def find_client_id
    client_id = (session[:user_return_to] || '').match(/[\?&;]client_id=([^&;]+)/).try(:[], 1)
    client_id = @pre_auth.client.try(:uid) if client_id.blank? && @pre_auth
    client_id
  end
end
