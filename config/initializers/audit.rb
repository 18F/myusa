require 'audit/user_action'

ActiveRecord::Base.extend Audit::UserAction::Model

ActionController::Base.around_filter Audit::UserAction::Sweeper.instance
