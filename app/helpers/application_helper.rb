
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

  def suffix_options
    [
      ['Jr.', 'Jr.'],
      ['Sr.', 'Sr.'],
      ['II', 'II'],
      ['III', 'III'],
      ['IV', 'IV']
    ]
  end

  def title_options
    [
      ['Mr.', 'Mr.'],
      ['Mrs.', 'Mrs.'],
      ['Miss', 'Miss'],
      ['Ms.', 'Ms.']
    ]
  end

  def us_state_options
    [
      ['Alabama', 'AL'],
      ['Alaska', 'AK'],
      ['Arizona', 'AZ'],
      ['Arkansas', 'AR'],
      ['California', 'CA'],
      ['Colorado', 'CO'],
      ['Connecticut', 'CT'],
      ['Delaware', 'DE'],
      ['District of Columbia', 'DC'],
      ['Florida', 'FL'],
      ['Georgia', 'GA'],
      ['Hawaii', 'HI'],
      ['Idaho', 'ID'],
      ['Illinois', 'IL'],
      ['Indiana', 'IN'],
      ['Iowa', 'IA'],
      ['Kansas', 'KS'],
      ['Kentucky', 'KY'],
      ['Louisiana', 'LA'],
      ['Maine', 'ME'],
      ['Maryland', 'MD'],
      ['Massachusetts', 'MA'],
      ['Michigan', 'MI'],
      ['Minnesota', 'MN'],
      ['Mississippi', 'MS'],
      ['Missouri', 'MO'],
      ['Montana', 'MT'],
      ['Nebraska', 'NE'],
      ['Nevada', 'NV'],
      ['New Hampshire', 'NH'],
      ['New Jersey', 'NJ'],
      ['New Mexico', 'NM'],
      ['New York', 'NY'],
      ['North Carolina', 'NC'],
      ['North Dakota', 'ND'],
      ['Ohio', 'OH'],
      ['Oklahoma', 'OK'],
      ['Oregon', 'OR'],
      ['Pennsylvania', 'PA'],
      ['Puerto Rico', 'PR'],
      ['Rhode Island', 'RI'],
      ['South Carolina', 'SC'],
      ['South Dakota', 'SD'],
      ['Tennessee', 'TN'],
      ['Texas', 'TX'],
      ['Utah', 'UT'],
      ['Vermont', 'VT'],
      ['Virginia', 'VA'],
      ['Washington', 'WA'],
      ['West Virginia', 'WV'],
      ['Wisconsin', 'WI'],
      ['Wyoming', 'WY']
    ]
  end

  def gender_options
    [
      ['Male', 'male'],
      ['Female', 'female']
    ]
  end

  def marital_status_options
    [
      ['Single', 'single'],
      ['Married', 'married'],
      ['Divorced', 'divorced'],
      ['Domestic Partnership', 'domestic_partnership'],
      ['Widowed', 'widowed']
    ]
  end

  def yes_no_options
    [['Yes', true], ['No', false]]
  end

  def yes_no_options_for_select(value)
    options_for_select(yes_no_options, value)
  end

  def not_me_path
    if params[:client_id].blank?
      destroy_user_session_path
    else
      new_params = params.slice(
        'client_id', 'redirect_uri', 'state', 'response_type', 'scope'
      ).merge(continue: oauth_authorization_path)
      destroy_user_session_path(new_params)
    end
  end
end
