class UserActionSweeper < ActionController::Caching::Sweeper
  observe ::UserAction

  def before(controller)
    @user = controller.send(:current_user)
    @ip = controller.request.remote_ip
  end

  def after(controller);
    @user = @ip = nil
  end

  def before_create(record)
    record.user = @user if record.user.nil?
    record.remote_ip = @ip if record.remote_ip.nil?
  end
end
