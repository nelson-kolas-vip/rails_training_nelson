require 'rails_helper'

RSpec.describe 'GET /api/v1/users/:id', type: :request do
  let!(:user) { create(:user) }

  describe 'GET /api/v1/users/:id' do
    context 'when the user exists' do
      it 'returns status 200 (OK)' do
        get "/api/v1/users/#{user.id}"

        expect(response).to have_http_status(:ok)
      end

      it 'returns correct user details' do
        get "/api/v1/users/#{user.id}"

        json = JSON.parse(response.body)
        expect(json['id']).to eq(user.id)
        expect(json['first_name']).to eq(user.first_name)
        expect(json['last_name']).to eq(user.last_name)
        expect(json['email']).to eq(user.email)
        expect(json).not_to have_key('password')
        expect(json).not_to have_key('encrypted_password')
      end

      it 'returns data in JSON format' do
        get "/api/v1/users/#{user.id}"
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'when the user does not exist' do
      it 'returns status 404' do
        get '/api/v1/users/999999'
        expect(response).to have_http_status(:not_found)
      end

      it 'returns error message in JSON' do
        get '/api/v1/users/999999'

        json = JSON.parse(response.body)
        expect(json['error']).to eq('User not found')
      end
    end

    context 'when the user ID is invalid (non-integer)' do
      it 'returns 404 Not Found' do
        get '/api/v1/users/invalid_id'
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the user ID is blank' do
      it 'returns 404 Not Found' do
        get '/api/v1/users/'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
