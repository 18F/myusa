class UserAction < ActiveRecord::Base
  belongs_to :user
  belongs_to :record, polymorphic: true

  scope :admin_action, -> { where(action: 'admin_action') }
end
