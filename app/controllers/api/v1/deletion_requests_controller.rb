class Api::V1::DeletionRequestsController < ApplicationController
  include Authenticable

  before_action :set_project, only: [:create]
  before_action :set_deletion_request, only: [:show, :update, :destroy]
  before_action :admin_required!, only: [:index, :update]

  def index
    deletion_requests = DeletionRequest.includes(:project, :user)
                                       .page(params[:page])
                                       .per(params[:per] || 10)

    render json: {
      deletion_requests: deletion_requests.map { |dr| deletion_request_json(dr) },
      pagination: pagination_meta(deletion_requests)
    }
  end

  def show
    # Users can see their own requests, admins can see all
    unless @deletion_request.user == current_user || current_user.admin?
      return render_unauthorized
    end

    render json: { deletion_request: deletion_request_json(@deletion_request) }
  end

  def create
    # Check if user can request deletion of this project
    unless @project.user == current_user || current_user.admin?
      return render_unauthorized('You can only request deletion of your own projects')
    end

    # Check for existing pending request
    existing_request = @project.deletion_requests.pending.where(user: current_user).first
    if existing_request
      return render json: {
        error: 'A deletion request for this project is already pending',
        deletion_request: deletion_request_json(existing_request)
      }, status: :conflict
    end

    deletion_request = @project.deletion_requests.build(deletion_request_params)
    deletion_request.user = current_user

    if deletion_request.save
      render json: {
        deletion_request: deletion_request_json(deletion_request),
        message: 'Deletion request submitted successfully. Admin will be notified.'
      }, status: :created
    else
      render json: {
        error: 'Deletion request failed',
        details: deletion_request.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    # Only admins can approve/reject deletion requests
    status = update_params[:status]

    unless %w[approved rejected].include?(status)
      return render json: { error: 'Status must be approved or rejected' }, status: :bad_request
    end

    if @deletion_request.update(update_params)
      message = "Deletion request #{status} successfully"

      # If approved, delete the project
      if status == 'approved'
        project_name = @deletion_request.project.name
        @deletion_request.project.destroy
        message += ". Project '#{project_name}' has been deleted."
      end

      render json: {
        deletion_request: deletion_request_json(@deletion_request),
        message: message
      }
    else
      render json: {
        error: 'Update failed',
        details: @deletion_request.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    # Users can cancel their own pending requests
    unless @deletion_request.user == current_user || current_user.admin?
      return render_unauthorized
    end

    unless @deletion_request.pending?
      return render json: { error: 'Can only cancel pending deletion requests' }, status: :bad_request
    end

    @deletion_request.destroy
    render json: { message: 'Deletion request cancelled successfully' }, status: :ok
  end

  def my_requests
    deletion_requests = current_user.deletion_requests
                                   .includes(:project)
                                   .page(params[:page])
                                   .per(params[:per] || 10)

    render json: {
      deletion_requests: deletion_requests.map { |dr| deletion_request_json(dr) },
      pagination: pagination_meta(deletion_requests)
    }
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_deletion_request
    @deletion_request = DeletionRequest.find(params[:id])
  end

  def deletion_request_params
    params.require(:deletion_request).permit(:reason, :status)
  end

  def update_params
    params.require(:deletion_request).permit(:status, :admin_notes)
  end

  def deletion_request_json(deletion_request)
    {
      id: deletion_request.id,
      reason: deletion_request.reason,
      status: deletion_request.status,
      admin_notes: deletion_request.admin_notes,
      user_id: deletion_request.user_id,
      user_name: deletion_request.user.name,
      user_email: deletion_request.user.email,
      project_id: deletion_request.project_id,
      project_name: deletion_request.project.name,
      created_at: deletion_request.created_at,
      updated_at: deletion_request.updated_at
    }
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
