class UserAction < ActiveRecord::Base
  belongs_to :user
  belongs_to :record, polymorphic: true
  serialize :data, JSON

  scope :for, ->(user) { where(user_id: user.id) }

  scope :successful_authentication, -> { where(action: 'successful_authentication') }
  scope :failed_authentication, -> { where(action: 'failed_authentication') }

  scope :api_access, -> { where(action: 'api_access') }
  scope :api_write, -> { where(action: 'api_write') }
end
