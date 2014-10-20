class Api::V1::TasksController < Api::ApiController
  doorkeeper_for :all, scopes: ['tasks']

  def index
    tasks = current_resource_owner.tasks.where(:app_id => doorkeeper_token.application.id).joins(:task_items)
    render :json => tasks.to_json(:include => :task_items), :status => 200
  end

  def create
    begin
      task = current_resource_owner.tasks.build(task_params)
      task.app_id = doorkeeper_token.application.id
      if task.save
        render :json => task.to_json(:include => :task_items), :status => 200
      else
        render :json => {:message => task.errors}, :status => 400
      end
    rescue ActionController::ParameterMissing
      render :json => { :message => "can't be blank"}, :status => 400
    end
  end

  def show
    task = current_resource_owner.tasks.find_by_id(params[:id])
    render :json => task.to_json(:include => :task_items), :status => 200
  end

  def update
      begin
        task = current_resource_owner.tasks.find(params[:id])
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
      end
    end

  protected

  def task_params
    params.require(:task).permit(:name, :completed_at, task_items_attributes:[:name])
  end

  def update_task_params
    params.require(:task).permit(:name, :completed_at, task_items_attributes:[:id, :name])
  end

end
