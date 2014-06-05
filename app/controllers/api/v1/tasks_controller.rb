class Api::V1::TasksController < Api::ApiController
  before_filter :oauthorize_scope

  def index
    tasks = @user.tasks.where(:app_id => @app.id).joins(:task_items)
    render :json => tasks.to_json(:include => :task_items), :status => 200
  end

  def create
    begin
      ActionController::Parameters.action_on_unpermitted_parameters = :raise
      task = @user.tasks.build(task_params)
      task.app_id = @app.id
      if task.save
        render :json => task.to_json(:include => :task_items), :status => 200
      else
        render :json => {:message => task.errors}, :status => 400
      end
    rescue ActionController::ParameterMissing
      render :json => { :message => "can't be blank"}, :status => 400
    rescue ActionController::UnpermittedParameters
      render :json => { :message => "Invalid parameters. Check your values and try again."}, :status => 422
    end
  end

  def show
    task = @token.owner.tasks.find_by_id(params[:id])
    render :json => task.to_json(:include => :task_items), :status => 200
  end

  def update
      begin
        ActionController::Parameters.action_on_unpermitted_parameters = :raise
        task = @user.tasks.find(params[:id])
        if task
          task.assign_attributes(update_task_params)
          task.complete! if params[:task][:completed]
          task.save!
        end
        render :json => task.to_json(:include => :task_items)
      rescue ActiveRecord::RecordNotFound
        render :json => { :message => "Invalid parameters. Check your values and try again."}, :status => 422
      rescue ActionController::ParameterMissing
        render :json => { :message => "can't be blank"}, :status => 400
      rescue ActionController::UnpermittedParameters
        render :json => { :message => "Invalid parameters. Check your values and try again."}, :status => 422
      end
    end

  protected
  
  def task_params
    params.require(:task).permit(:name, :completed_at, task_items_attributes:[:name])
  end
  
  def update_task_params
    params.require(:task).permit(:name, :completed_at, task_items_attributes:[:id, :name])
  end

  def no_scope_message
    "You do not have permission to #{self.action_name == 'create' ? 'create' : 'view'} tasks for that user."
  end

  def oauthorize_scope
    validate_oauth(OauthScope.where(scope_name: 'tasks'))
  end
end