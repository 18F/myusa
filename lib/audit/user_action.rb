module Audit
  module UserAction
    module Model
      def audit_on(*events)
        opts = events.last.is_a?(Hash) ? events.pop : {}

        audit_wrapper = Wrapper.new(opts)
        hooks = events.map {|e| "after_#{e}".to_sym }

        hooks.each {|h| send h, audit_wrapper }
      end
    end

    class Sweeper < ActionController::Caching::Sweeper
      observe ::UserAction

      attr_accessor :controller

      def before(controller)
        self.controller = controller
      end

      def after(controller); end
      #   self.controller = controller
      # end

      def before_create(record)
        record.remote_ip = controller.presence && controller.request.remote_ip
      end
    end

    class Wrapper
      def initialize(opts)
        @action = opts[:action] if opts.has_key?(:action)
        @user_method = opts[:user].presence || :user
      end

      def after_create(record)
        audit(@action || 'create', record)
      end

      private

      def get_user(record)
        record.send(@user_method) if record.respond_to?(@user_method)
      end

      def audit(action, record)
        ::UserAction.create(user: get_user(record), record: record, action: action)
      end
    end
  end
end
