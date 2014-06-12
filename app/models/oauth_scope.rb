class OauthScope < ActiveRecord::Base
  validates_presence_of :name, :scope_name, :scope_type
  validates_uniqueness_of :scope_name
  validates :scope_type, :inclusion => {:in => ["app", "user"]}
#  attr_accessible :description, :name, :scope_name, :scope_type, :as => [:default, :admin]
  
  scope :top_level_scopes, -> { where("scope_name NOT LIKE :dot", :dot => "%.%") }
  scope :profile_scopes, -> {where("scope_name LIKE :profile_pattern", :profile_pattern => "profile%")}
  
  def is_parent?
    OauthScope.all.any?{|s| s.scope_name.match(/#{self.name}\./i)}
  end

  def parent_readable_name
    return "Read user's profile information" if self.name == "Profile"
    return "Create tasks in user's account" if self.name == "Tasks"
    return "Send notifications to user"     if self.name == "Notifications"

    return self.description
  end

  def readable_name
    self.scope_name.sub(/^.+\./, "").gsub(/_/, " ").gsub(/(\d+)/," " + '\1' + " ").capitalize
  end
  
  def self.seed_data
    [
      {name: 'Verify credentials', description: 'Verify application credentials', scope_name: 'verify_credentials', :scope_type => 'app'},
      {name: 'Profile', description: 'Read your profile information', scope_name: 'profile', :scope_type => 'user'},
      {name: 'Profile email', description: 'Read your email address', scope_name: 'profile.email', :scope_type => 'user'},
      {name: 'Profile title', description: 'Read your title (Mr./Mrs./Miss, etc.)', scope_name: 'profile.title', :scope_type => 'user'},
      {name: 'Profile first name', description: 'Read your first name', scope_name: 'profile.first_name', :scope_type => 'user'},
      {name: 'Profile middle name', description: 'Read your middle name', scope_name: 'profile.middle_name', :scope_type => 'user'},
      {name: 'Profile last name', description: 'Read your last name', scope_name: 'profile.last_name', :scope_type => 'user'},
      {name: 'Profile suffic', description: 'Read your suffix (Sr./Jr./III, etc.)', scope_name: 'profile.suffix', :scope_type => 'user'},
      {name: 'Profile address', description: 'Read your address', scope_name: 'profile.address', :scope_type => 'user'},
      {name: 'Profile address (2)', description: 'Read your address (2)', scope_name: 'profile.address2', :scope_type => 'user'},
      {name: 'Profile city', description: 'Read your city', scope_name: 'profile.city', :scope_type => 'user'},
      {name: 'Profile state', description: 'Read your state', scope_name: 'profile.state', :scope_type => 'user'},
      {name: 'Profile zip', description: 'Read your zip code', scope_name: 'profile.zip', :scope_type => 'user'},
      {name: 'Profile phone number', description: 'Read your phone number', scope_name: 'profile.phone_number', :scope_type => 'user'},
      {name: 'Profile mobile number', description: 'Read your mobile number', scope_name: 'profile.mobile_number', :scope_type => 'user'},
      {name: 'Profile gender', description: 'Read your gender', scope_name: 'profile.gender', :scope_type => 'user'},
      {name: 'Profile marital status', description: 'Read your marital status', scope_name: 'profile.marital_status', :scope_type => 'user'},
      {name: 'Profile parent', description: 'Read your parent status', scope_name: 'profile.is_parent', :scope_type => 'user'},
      {name: 'Profile student', description: 'Read your student status', scope_name: 'profile.is_student', :scope_type => 'user'},
      {name: 'Profile veteran', description: 'Read your veteran status', scope_name: 'profile.is_veteran', :scope_type => 'user'},
      {name: 'Profile retiree', description: 'Read your retiree status', scope_name: 'profile.is_retired', :scope_type => 'user'},
      {name: 'Tasks', description: 'Create tasks in your account', scope_name: 'tasks', :scope_type => 'user'},
      {name: 'Notifications', description: 'Send you notifications', scope_name: 'notifications', :scope_type => 'user'}
    ]
  end
end
