module AuthenticationHelpers
  def generate_jwt_token(user)
    JwtService.encode(user_id: user.id)
  end

  def authenticated_headers(user)
    token = generate_jwt_token(user)
    { 'Authorization' => "Bearer #{token}" }
  end

  def json_response
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :controller
  config.include AuthenticationHelpers, type: :request
end
