
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
    true_values = ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES
    true_values.include?(value) ? 'Yes' : 'No'
  end
end
