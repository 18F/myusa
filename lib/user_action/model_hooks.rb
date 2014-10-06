module UserAction::ModelHooks
  def audit_on(*events)
    opts = events.last.is_a?(Hash) ? events.pop : {}

    callback_opts = opts.slice(:if, :unless)
    wrapper_opts = opts.slice(:action)

    audit_wrapper = UserAction::AuditWrapper.new(opts)
    hooks = events.map {|e| "after_#{e}".to_sym }

    hooks.each {|h| send h, audit_wrapper, callback_opts }
  end
end
