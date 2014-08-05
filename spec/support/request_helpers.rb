require 'spec_helper'

def create_confirmed_user_with_profile(args={})
  profile = {
    email: 'joe@citizen.org',
    first_name: 'Joe',
    last_name: 'Citizen',
    is_student: true
  }.merge(args)

  User.create! do |user|
    user.email = profile.delete(:email)
    user.profile = user.build_profile(profile)
  end
end
