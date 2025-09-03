class Api::V1::TasksController < ApplicationController
  include Authenticable

  before_action :set_project, only: [:index, :create]
  before_action :set_task, only: [:show, :update, :destroy]
  before_action :check_project_access, only: [:index, :create]
  before_action :check_task_access, only: [:show, :update, :destroy]

  def index
    tasks = @project.tasks.includes(:user)
    tasks = apply_filters(tasks)
    tasks = tasks.page(params[:page]).per(params[:per] || 10)

    render json: {
      tasks: tasks.map { |task| task_json(task) },
      pagination: pagination_meta(tasks)
    }
  end

  def show
    render json: { task: task_json(@task) }
  end

  def create
    task = @project.tasks.build(task_params)
    task.user = current_user

    if task.save
      render json: { task: task_json(task) }, status: :created
    else
      render json: {
        error: 'Task creation failed',
        details: task.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      render json: { task: task_json(@task) }
    else
      render json: {
        error: 'Task update failed',
        details: @task.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    render json: { message: 'Task deleted successfully' }, status: :ok
  end

  def my_tasks
    tasks = current_user.tasks.includes(:project, :user)
    tasks = apply_filters(tasks)
    tasks = tasks.page(params[:page]).per(params[:per] || 10)

    render json: {
      tasks: tasks.map { |task| task_json(task, include_project: true) },
      pagination: pagination_meta(tasks)
    }
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = Task.find(params[:id])
  end

  def check_project_access
    return render_unauthorized unless @project.accessible_by?(current_user)
  end

  def check_task_access
    return render_unauthorized unless @task.project.accessible_by?(current_user)
  end

  def apply_filters(tasks)
    tasks = tasks.by_status(params[:status]) if params[:status].present?
    tasks = tasks.by_priority(params[:priority]) if params[:priority].present?
    tasks = tasks.where('due_date >= ?', params[:due_date_from]) if params[:due_date_from].present?
    tasks = tasks.where('due_date <= ?', params[:due_date_to]) if params[:due_date_to].present?
    tasks
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :priority, :due_date)
  end

  def task_json(task, include_project: false)
    result = {
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      due_date: task.due_date,
      user_id: task.user_id,
      user_name: task.user.name,
      project_id: task.project_id,
      created_at: task.created_at,
      updated_at: task.updated_at
    }

    if include_project
      result[:project] = {
        id: task.project.id,
        name: task.project.name,
        visibility: task.project.visibility
      }
    end

    result
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      per_page: collection.limit_value,
      total_pages: collection.total_pages,
      total_count: collection.total_count
    }
  end
end
