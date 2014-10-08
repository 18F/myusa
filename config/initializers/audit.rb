require 'audit/user_action'

ActiveRecord::Base.extend Audit::UserAction::Model

ActionController::Base.around_filter Audit::UserAction::Sweeper.instance

Warden::Manager.before_logout do |user, auth, opts|
  ::UserAction.create(action: 'log_out', user: user)
end
