module Audit
  module UserAction
    module Model
      def audit_on(*events)
        audit_wrapper = Wrapper.new
        hooks = events.map {|e| "after_#{e}".to_sym }

        hooks.each {|h| send h, audit_wrapper }
      end
    end

    class Sweeper < ActionController::Caching::Sweeper
      observe ::UserAction

      attr_accessor :controller

      def before(controller)
        self.controller = controller
        true
      end

      def after(controller)
        self.controller = nil
      end

      def before_create(record)
        if self.controller.present?
          record.user = self.controller.send(:current_user)
          record.remote_ip = self.controller.request.remote_ip
        end
      end
    end

    class Wrapper
      def after_create(record)
        audit('create', record)
      end

      private

      def audit(action, record)
        ::UserAction.create(record: record, action: action)
      end
    end
  end
end

Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
  ::UserAction.create(action: 'sign_in')
end

Warden::Manager.before_logout do |user, auth, opts|
  ::UserAction.create(action: 'sign_out')
end
