class Api::V1::TasksController < Api::ApiController
  doorkeeper_for :all, scopes: ['tasks']
  wrap_parameters :task, include: [:name, :url, :completed_at, :task_items_attributes]
  before_filter :lookup_task, :only => [:show, :update, :destroy]

  def index
    @tasks = current_resource_owner.tasks.where(app_id: doorkeeper_token.application.id).joins(:task_items)
    render json: @tasks.to_json(include: :task_items), status: 200
  end

  def create
    @task = current_resource_owner.tasks.build(task_params)
    @task.app_id = doorkeeper_token.application.id
    if @task.save
      render json: @task.to_json(include: :task_items), status: 200
    else
      render json: { message: @task.errors }, status: 400
    end
  rescue ActionController::ParameterMissing
    render json: { message: "can't be blank" }, status: 400
  end

  def show
    render json: @task.to_json(include: :task_items), status: 200
  end

  def update
    @task.assign_attributes(update_task_params)
    @task.complete! if params[:task][:completed]
    @task.save!
    render json: @task.to_json(include: :task_items)
  rescue ActionController::ParameterMissing
    render json: { message: "can't be blank" }, status: 400
  end

  def destroy
    @task.destroy
    render json: @task.to_json(include: :task_items), status: 200
  end

  private

  def lookup_task
    @task = current_resource_owner.tasks.where(:app_id => doorkeeper_token.application.id).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    if Task.where(id: params[:id]).exists?
      raise RecordBelongsToAnother
    else
      raise
    end
  end

  def resources
    @tasks.presence || [@task]
  end

  def task_params
    params.require(:task).permit(:name, :url, :completed_at, task_items_attributes: [:name, :external_id, :url, :completed_at])
  end

  def update_task_params
    params.require(:task).permit(:name, :url, :completed_at, task_items_attributes: [:id, :name, :external_id, :url, :completed_at])
  end
end
