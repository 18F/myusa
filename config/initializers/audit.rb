require 'audit/user_action'

ActiveRecord::Base.extend Audit::UserAction::Model

ActionController::Base.around_filter Audit::UserAction::Sweeper.instance

Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
  ::UserAction.create(action: 'sign_in', user: user)
end

Warden::Manager.before_logout do |user, auth, opts|
  ::UserAction.create(action: 'sign_out', user: user)
end
