module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  def authenticate_user!
    header = request.headers['Authorization']
    return render_unauthorized unless header

    token = header.split(' ').last
    begin
      decoded = JwtService.decode(token)
      @current_user = User.find(decoded[:user_id])
    rescue StandardError
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def render_unauthorized(message = 'Unauthorized')
    render json: { error: message }, status: :unauthorized
  end

  def admin_required!
    render_unauthorized('Admin access required') unless current_user&.admin?
  end
end
