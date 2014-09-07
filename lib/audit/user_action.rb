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

      def before(controller)
        self.controller = controller
      end

      def after(controller);
        self.controller = nil
      end

      def before_create(record)
        if controller.present?
          record.user = controller.send(:current_user)
          record.remote_ip = controller.request.remote_ip
        end
      end
    end

    class Wrapper
      def initialize(opts)
        @action = opts[:action] if opts.has_key?(:action)
      end

      def after_create(record)
        audit(@action || 'create', record)
      end

      private

      def audit(action, record)
        ::UserAction.create(record: record, action: action)
      end
    end
  end
end
