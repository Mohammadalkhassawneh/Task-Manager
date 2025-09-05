require 'rails_helper'

RSpec.describe Api::V1::AuthController, type: :controller do
  describe 'POST #login' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns JWT token and user info' do
        post :login, params: { auth: { email: 'test@example.com', password: 'password123' } }

        expect(response).to have_http_status(:ok)
        expect(json_response).to have_key('token')
        expect(json_response['user']['email']).to eq('test@example.com')
        expect(json_response['user']['id']).to eq(user.id)
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized error' do
        post :login, params: { auth: { email: 'test@example.com', password: 'wrong' } }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'returns unauthorized for non-existent user' do
        post :login, params: { auth: { email: 'nonexistent@example.com', password: 'password123' } }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Invalid email or password')
      end
    end

    context 'with missing parameters' do
      it 'returns unauthorized for missing email' do
        post :login, params: { auth: { password: 'password123' } }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Invalid email or password')
      end
    end
  end

  describe 'POST #register' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          auth: {
            name: 'John Doe',
            email: 'john@example.com',
            password: 'password123',
            role: 'user'
          }
        }
      end

      it 'creates user and returns JWT token' do
        expect {
          post :register, params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response).to have_key('token')
        expect(json_response['user']['email']).to eq('john@example.com')
        expect(json_response['user']['name']).to eq('John Doe')
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors for duplicate email' do
        create(:user, email: 'john@example.com')

        post :register, params: {
          auth: {
            name: 'John Doe',
            email: 'john@example.com',
            password: 'password123'
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Registration failed')
        expect(json_response['details']).to include('Email has already been taken')
      end

      it 'returns validation errors for short password' do
        post :register, params: {
          auth: {
            name: 'John Doe',
            email: 'john@example.com',
            password: '123'
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['details']).to include('Password is too short (minimum is 6 characters)')
      end
    end
  end
end
