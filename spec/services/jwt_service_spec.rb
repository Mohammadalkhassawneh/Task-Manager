require 'rails_helper'

RSpec.describe JwtService do
  let(:payload) { { user_id: 123, role: 'user' } }

  describe '.encode' do
    it 'generates a JWT token' do
      token = JwtService.encode(payload)
      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3) # JWT has 3 parts
    end

    it 'includes expiration in payload' do
      token = JwtService.encode(payload)
      decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
      expect(decoded['exp']).to be_present
    end

    it 'accepts custom expiration' do
      custom_exp = 1.hour.from_now
      token = JwtService.encode(payload, custom_exp)
      decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
      expect(decoded['exp']).to eq(custom_exp.to_i)
    end
  end

  describe '.decode' do
    let(:token) { JwtService.encode(payload) }

    it 'decodes a valid token' do
      decoded = JwtService.decode(token)
      expect(decoded['user_id']).to eq(123)
      expect(decoded['role']).to eq('user')
    end

    it 'returns HashWithIndifferentAccess' do
      decoded = JwtService.decode(token)
      expect(decoded).to be_a(HashWithIndifferentAccess)
      expect(decoded[:user_id]).to eq(123)
    end

    it 'raises error for invalid token' do
      expect {
        JwtService.decode('invalid.token.here')
      }.to raise_error(StandardError, /Invalid token/)
    end

    it 'raises error for expired token' do
      expired_token = JwtService.encode(payload, 1.second.ago)
      expect {
        JwtService.decode(expired_token)
      }.to raise_error(StandardError, /Invalid token/)
    end
  end
end
