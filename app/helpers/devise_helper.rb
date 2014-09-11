module DeviseHelper
  include Devise::Controllers::StoreLocation

  def devise_error_messages!
    return '' if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block"> <button type="button"
    class="close" data-dismiss="alert">x</button>
      #{messages}
    </div>
    HTML

    html.html_safe
  end

  def client_app
    @client_app ||= params[:client_id].presence &&
                    Doorkeeper::Application.find_by_uid(params[:client_id])
  end


end
