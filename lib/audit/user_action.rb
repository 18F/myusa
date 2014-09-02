module Audit
  module UserAction
    module Model
      def audit_on(*events)
        opts = events.last.is_a?(Hash) ? events.pop : {}

        audit_wrapper = Wrapper.new(opts)
        hooks = events.map {|e| "after_#{e}".to_sym }

        has_many :user_action, as: :record
        hooks.each {|h| send h, audit_wrapper }
      end
    end

    class Wrapper
      def initialize(opts={})
        @user_method = opts.has_key?(:user) ? opts[:user] : :user
      end

      def after_create(record)
        audit('create', record)
      end

      private

      def audit(action, record)
        ::UserAction.create(user: record.send(@user_method),
                            record: record,
                            action: action)
      end
    end
  end
end
