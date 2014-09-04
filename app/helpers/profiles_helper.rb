
# ProfilesHelper
module ProfilesHelper
  def suffix_options
    [
      ['Jr.', 'Jr.'],
      ['Sr.', 'Sr.'],
      ['II', 'II'],
      ['III', 'III'],
      ['IV', 'IV']
    ]
  end
  def suffix_options_for_select(value)
    options_for_select(suffix_options, value)
  end

  def title_options
    [
      ['Mr.', 'Mr.'],
      ['Mrs.', 'Mrs.'],
      ['Miss', 'Miss'],
      ['Ms.', 'Ms.']
    ]
  end
  def title_options_for_select(value)
    options_for_select(title_options, value)
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
  def us_state_options_for_select(value)
    options_for_select(us_state_options, value)
  end

  def gender_options
    [
      ['Male', 'male'],
      ['Female', 'female']
    ]
  end
  def gender_options_for_select(value)
    options_for_select(gender_options, value)
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
  def maritial_status_options_for_select(value)
    options_for_select(marital_status_options, value)
  end

  def yes_or_no(value)
    return '' if value.nil?
    value ? 'Yes' : 'No'
  end

  def profile_display_value(field, value)
    case field
    when :state
      us_state_options.map(&:reverse).to_h[value]
    when :gender
      gender_options.map(&:reverse).to_h[value]
    when :marital_status
      marital_status_options.map(&:reverse).to_h[value]
    when :is_parent
      yes_or_no(value)
    when :is_student
      yes_or_no(value)
    when :is_veteran
      yes_or_no(value)
    when :is_retired
      yes_or_no(value)
    else
      value
    end
  end

end
