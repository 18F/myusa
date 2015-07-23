class ApiSweeper < ActionController::Caching::Sweeper
  observe Task, TaskItem, Notification

  def before(controller)
    @user = controller.send(:current_resource_owner)
    @action = controller.params[:action]
  end

  def after(controller);
    @user = @action = nil
  end

  def after_save(record)
    UserAction.create(
      user: @user,
      action: "api_write",
      record: record,
      data: { action: @action  }
    )
  end

  def after_destroy(record)
    UserAction.create(
      user: @user,
      action: "api_destroy",
      record: record,
      data: { action: @action  }
    )
  end
end
