class Api::V1::UsersController < ApplicationController
  include Authenticable

  def index
    return unless admin_required!
    
    users = User.all
    render json: {
      users: users.map { |user| user_json(user) }
    }
  end

  def show
    user = User.find(params[:id])
    render json: { user: user_json(user) }
  end

  def me
    render json: { user: user_json(current_user) }
  end

  def update
    user = params[:id] ? User.find(params[:id]) : current_user

    if user != current_user && !current_user.admin?
      return render_unauthorized('You can only update your own profile')
    end

    if user.update(user_params)
      render json: { user: user_json(user) }
    else
      render json: {
        error: 'Update failed',
        details: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    allowed_params = [:name, :email]
    allowed_params << :role if current_user.admin?
    params.require(:user).permit(*allowed_params)
  end

  def user_json(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end
