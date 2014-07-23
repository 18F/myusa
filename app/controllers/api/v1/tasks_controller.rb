class Api::V1::TasksController < Api::ApiController
  before_filter :oauthorize_scope

 
  #GET /api/tasks
  #
  #List all tasks, and associated attributes, created by the calling application
  def index
    tasks = @user.tasks.where(:app_id => @app.id).joins(:task_items)
    render :json => tasks.to_json(:include => :task_items), :status => 200
  end

  #POST /api/tasks
  #
  #Create a new task for the user for this application.
  #
  # + Parameters
  #
  #  + name (required, string, `Test task`) ...The name for the task that is being created.
  #  + task_items_atributes(optional, hash, `{:id=>1, :name=>'Task attribute' }`) ...A list of task items to be associated with the task.
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

  #GET /api/task/:id
  #
  #Get a single task.
  def show
    task = @token.owner.tasks.find_by_id(params[:id])
    render :json => task.to_json(:include => :task_items), :status => 200
  end

  #PUT /api/task/:id
  #
  #Update a task
  #
  # + Parameters
  #
  #  + name (optional, string, `Test task`) ...The updated name of the task.
  #  + task_items_atributes(optional, hash, `{:id=>1, :name=>'Task attribute' }`)... The updated task items that are associated with the task.
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