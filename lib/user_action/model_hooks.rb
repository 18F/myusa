module UserAction::ModelHooks
  def audit_on(*events)
    opts = events.last.is_a?(Hash) ? events.pop : {}

    callback_opts = opts.slice(:if, :unless)
    wrapper_opts = opts.slice(:action)

    audit_wrapper = AuditWrapper.new(opts)

    events.each {|e| send e, audit_wrapper, callback_opts }
  end
end
