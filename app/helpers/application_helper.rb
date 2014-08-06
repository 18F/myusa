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
    app = App.find_by_return_to_url(session[:user_return_to])
    return nil if app.nil? || app.url.blank?
    link_to("Return to #{app.name}", app.url, class: 'back-to-app')
  end
end
