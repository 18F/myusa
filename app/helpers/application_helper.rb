
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

  def yes_or_no(value)
    return '' if value.nil?
    value ? 'Yes' : 'No'
  end

  def yes_no_options
    [['Yes', true], ['No', false]]
  end
end
