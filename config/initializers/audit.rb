require 'audit/user_action'

ActiveRecord::Base.extend Audit::UserAction::Model
