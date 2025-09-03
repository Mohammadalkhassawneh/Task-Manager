class Api::V1::AuthController < ApplicationController
  def login
    user = User.find_by(email: login_params[:email])

    if user&.authenticate(login_params[:password])
      token = JwtService.encode(user_id: user.id)
      render json: {
        token: token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role
        }
      }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def register
    user = User.new(register_params)

    if user.save
      token = JwtService.encode(user_id: user.id)
      render json: {
        token: token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role
        }
      }, status: :created
    else
      render json: {
        error: 'Registration failed',
        details: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def login_params
    params.require(:auth).permit(:email, :password)
  end

  def register_params
    params.require(:auth).permit(:name, :email, :password, :role)
  end
end
