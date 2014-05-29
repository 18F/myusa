require 'spec_helper'
include Warden::Test::Helpers

def create_confirmed_user_with_profile(email_or_hash = {})
  email_or_hash = {email: email_or_hash} unless email_or_hash.kind_of? Hash
  profile = email_or_hash.reverse_merge(email: 'joe@citizen.org', password: 'Password1',
                                        first_name: 'Joe', last_name: 'Citizen', is_student: true)
  user_create_hash = profile.select {|key,val| [:email, :password].member?(key)}
  user = User.create!(user_create_hash)
  profile_create_hash = profile.select {|key,val| Profile.new.methods.map(&:to_sym).select{ |m| m != :email }.member?(key)}
  user.profile = Profile.new(profile_create_hash)
  user.confirm!
  user
end

def login(user)
  login_as user, scope: :user
end
