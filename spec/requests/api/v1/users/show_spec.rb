require 'rails_helper'

RSpec.describe 'GET /api/v1/users/:id', type: :request do
  let!(:user) { create(:user, first_name: 'John', last_name: 'Doe') }
  let(:user_id) { user.id }

  describe 'when the user exists' do
    before { get "/api/v1/users/#{user_id}" }

    it 'returns a 200 OK status' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct user details in JSON' do
      json = JSON.parse(response.body)
      expect(json['id']).to eq(user.id)
      expect(json['first_name']).to eq('John')
      expect(json['last_name']).to eq('Doe')
      expect(json['email']).to eq(user.email)
    end

    it 'does not return sensitive information like password' do
      json = JSON.parse(response.body)
      expect(json).not_to have_key('password')
      expect(json).not_to have_key('password_confirmation')
      expect(json).not_to have_key('encrypted_password')
    end

    it 'returns the content in the application/json format' do
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end
  end

  describe 'when the user does not exist' do
    let(:non_existent_user_id) { user.id + 100 }

    before { get "/api/v1/users/#{non_existent_user_id}" }

    it 'returns a 404 Not Found status' do
      expect(response).to have_http_status(:not_found)
    end

    it 'returns a "User not found" error message' do
      json = JSON.parse(response.body)
      expect(json['error']).to eq('User not found')
    end
  end

  describe 'when the user ID is invalid' do
    context 'with a non-integer ID' do
      before { get '/api/v1/users/invalid-id' }

      it 'returns a 404 Not Found status' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns a "User not found" error message' do
        json = JSON.parse(response.body)
        expect(json['error']).to eq('User not found')
      end
    end

    context 'with a zero ID' do
      before { get '/api/v1/users/0' }

      it 'returns a 404 Not Found status' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns a "User not found" error message' do
        json = JSON.parse(response.body)
        expect(json['error']).to eq('User not found')
      end
    end
  end

  describe 'when the user ID is blank' do
    it 'returns a 404 Not Found status and a blank ID error' do
      allow_any_instance_of(Api::V1::UsersController).to receive(:params) do
        ActionController::Parameters.new(id: '').permit!
      end
      get '/api/v1/users/1'

      expect(response).to have_http_status(:not_found)

      json = JSON.parse(response.body)
      expect(json['error']).to eq('ID is blank')
    end
  end
end
