class Api::V1::TaskItemsController < Api::ApiController
	doorkeeper_for :all, scopes: ['tasks']
  before_filter :lookup_task
  wrap_parameters :task_item

  def index
    @task_items = @task.task_items
    render :json => @task_items.to_json, :status => 200
  end

  def create
    begin
      @task_item = @task.task_items.build(task_params)
      if @task_item.save
        render :json => @task_item.to_json, :status => 200
      else
        render :json => {:message => @task_item.errors}, :status => 400
      end
    rescue ActionController::ParameterMissing
      render :json => { :message => "can't be blank"}, :status => 400
    end
  end

  def show
    @task_item = @task.task_items.find_by_id(params[:id])
    render :json => @task_item.to_json, :status => 200
  end

  def update
    begin
      if @task_item = @task.task_items.find(params[:id])
        @task_item.assign_attributes(update_task_params)
        @task_item.save!
        @task_item.complete! if params["task_item"]["complete"] # should they be posting up complete or completed_at
      end

      render :json => @task_item.to_json
    rescue ActionController::ParameterMissing
      render :json => { :message => "can't be blank"}, :status => 400
    end
  end

  def destroy
    @task_item = @task.task_items.find(params[:id])
    @task_item.destroy

    render :json => @task_item, :status => 200
  end


private
  def lookup_task
    @task = current_resource_owner.tasks.where(:app_id => doorkeeper_token.application.id).find(params[:task_id])
  end

  def resources
    @task_items.presence || [ @task_item ]
  end

  def task_params
    params.require(:task_item).permit(:name, :url, :external_id, :complete, :completed_at)
  end

  def update_task_params
    params.require(:task_item).permit(:name, :url, :external_id, :completed_at)
  end
end