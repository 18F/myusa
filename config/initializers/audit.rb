require 'user_action/audit_wrapper'
require 'user_action/model_hooks'

ActiveRecord::Base.extend UserAction::ModelHooks

ActionController::Base.around_filter UserActionSweeper.instance

Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
  ::UserAction.create(action: 'sign_in', user: user)
end

Warden::Manager.before_logout do |user, auth, opts|
  ::UserAction.create(action: 'sign_out', user: user)
end
