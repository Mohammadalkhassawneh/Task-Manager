class Api::V1::ProjectsController < ApplicationController
  include Authenticable

  before_action :set_project, only: [:show, :update, :destroy]
  before_action :check_project_access, only: [:show, :update]
  before_action :check_project_ownership_or_admin, only: [:destroy]

  def index
    projects = current_user.admin? ? Project.all : accessible_projects
    projects = projects.page(params[:page]).per(params[:per] || 10)

    render json: {
      projects: projects.map { |project| project_json(project) },
      pagination: pagination_meta(projects)
    }
  end

  def show
    render json: { project: project_json(@project, include_tasks: true) }
  end

  def create
    project = current_user.projects.build(project_params)

    if project.save
      render json: { project: project_json(project) }, status: :created
    else
      render json: {
        error: 'Project creation failed',
        details: project.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      render json: { project: project_json(@project) }
    else
      render json: {
        error: 'Project update failed',
        details: @project.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.admin?
      @project.destroy
      render json: { message: 'Project deleted successfully' }, status: :ok
    else
      render_unauthorized('Only admins can delete projects')
    end
  end

  def export_tasks
    project = Project.find(params[:id])
    return render_unauthorized unless project.accessible_by?(current_user)

    csv_data = generate_tasks_csv(project)

    send_data csv_data,
              filename: "#{project.name.parameterize}-tasks-#{Date.current}.csv",
              type: 'text/csv',
              disposition: 'attachment'
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def check_project_access
    return render_unauthorized unless @project.accessible_by?(current_user)
  end

  def check_project_ownership_or_admin
    unless @project.user == current_user || current_user.admin?
      render_unauthorized('You can only delete your own projects or be an admin')
    end
  end

  def accessible_projects
    Project.joins("LEFT JOIN project_permissions ON projects.id = project_permissions.project_id")
           .where(
             "projects.user_id = ? OR projects.visibility = ? OR " \
             "(projects.visibility = ? AND project_permissions.user_id = ?)",
             current_user.id,
             Project.visibilities[:public_access],
             Project.visibilities[:shared],
             current_user.id
           ).distinct
  end

  def project_params
    params.require(:project).permit(:name, :description, :visibility)
  end

  def project_json(project, include_tasks: false)
    result = {
      id: project.id,
      name: project.name,
      description: project.description,
      visibility: project.visibility,
      user_id: project.user_id,
      user_name: project.user.name,
      created_at: project.created_at,
      updated_at: project.updated_at
    }

    if include_tasks
      result[:tasks] = project.tasks.map { |task| task_json(task) }
    end

    result
  end

  def task_json(task)
    {
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      due_date: task.due_date,
      user_id: task.user_id,
      user_name: task.user.name,
      created_at: task.created_at,
      updated_at: task.updated_at
    }
  end

  def generate_tasks_csv(project)
    require 'csv'

    CSV.generate(headers: true) do |csv|
      csv << ['Title', 'Description', 'Status', 'Priority', 'Due Date', 'Assigned To', 'Created At', 'Updated At']

      project.tasks.includes(:user).each do |task|
        csv << [
          task.title,
          task.description,
          task.status.humanize,
          task.priority.humanize,
          task.due_date&.strftime('%Y-%m-%d'),
          task.user.name,
          task.created_at.strftime('%Y-%m-%d %H:%M'),
          task.updated_at.strftime('%Y-%m-%d %H:%M')
        ]
      end
    end
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
