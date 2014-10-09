require 'user_action/audit_wrapper'
require 'user_action/model_hooks'

ActiveRecord::Base.extend UserAction::ModelHooks

ActionController::Base.around_filter UserActionSweeper.instance

Warden::Manager.before_logout do |user, auth, opts|
  ::UserAction.create(action: 'log_out', user: user)
end
