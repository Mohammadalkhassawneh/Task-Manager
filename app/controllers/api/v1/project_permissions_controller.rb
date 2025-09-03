class Api::V1::ProjectPermissionsController < ApplicationController
  include Authenticable

  before_action :set_project
  before_action :check_project_ownership, except: [:index]
  before_action :set_permission, only: [:show, :destroy]

  def index
    # Users can see permissions for projects they own or have access to
    unless @project.accessible_by?(current_user)
      return render_unauthorized
    end

    permissions = @project.project_permissions.includes(:user)

    render json: {
      permissions: permissions.map { |permission| permission_json(permission) }
    }
  end

  def show
    render json: { permission: permission_json(@permission) }
  end

  def create
    user = User.find(permission_params[:user_id])

    # Check if permission already exists
    existing_permission = @project.project_permissions.find_by(user: user)
    if existing_permission
      return render json: {
        error: 'Permission already exists for this user',
        permission: permission_json(existing_permission)
      }, status: :conflict
    end

    permission = @project.project_permissions.build(
      user: user,
      permission_type: permission_params[:permission_type] || 'read'
    )
    
    if permission.save
      render json: { 
        permission: permission_json(permission),
        message: "#{permission.permission_type.humanize} permission granted to #{user.name}"
      }, status: :created
    else
      render json: {
        error: 'Permission creation failed',
        details: permission.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    user_name = @permission.user.name
    @permission.destroy
    render json: { 
      message: "Permission revoked from #{user_name}"
    }, status: :ok
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_permission
    @permission = @project.project_permissions.find(params[:id])
  end

  def check_project_ownership
    unless @project.user == current_user || current_user.admin?
      render_unauthorized('Only project owners can manage permissions')
    end
  end

  def permission_params
    params.require(:project_permission).permit(:user_id, :permission_type)
  end

  def permission_json(permission)
    {
      id: permission.id,
      user_id: permission.user_id,
      user_name: permission.user.name,
      user_email: permission.user.email,
      project_id: permission.project_id,
      project_name: permission.project.name,
      permission_type: permission.permission_type,
      created_at: permission.created_at,
      updated_at: permission.updated_at
    }
  end
end
