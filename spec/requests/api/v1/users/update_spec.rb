require 'rails_helper'

RSpec.describe 'API::V1::Users#update', type: :request do
  let!(:user) { create(:user, email: 'john@example.com', password: 'happyface', password_confirmation: 'happyface') }
  let(:headers) { { 'Content-Type': 'application/json' } }

  describe 'PUT /api/v1/users/:id' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          first_name: 'UpdatedName',
          last_name: 'UpdatedLast',
          email: 'new_email@example.com',
          phone_number: '9876543210',
          age: 30
        }
      end

      it 'updates the user and returns 200 OK' do
        put "/api/v1/users/#{user.id}", params: valid_params.to_json, headers: headers

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json['first_name']).to eq('UpdatedName')
        expect(json['email']).to eq('new_email@example.com')
      end
    end

    context 'with only one field provided' do
      it 'updates only that field and leaves others unchanged' do
        put "/api/v1/users/#{user.id}", params: { last_name: 'SoloChange' }.to_json, headers: headers

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json['last_name']).to eq('SoloChange')
        expect(json['email']).to eq('john@example.com')
      end
    end

    context 'with invalid ID' do
      it 'returns 404 not found' do
        put '/api/v1/users/999999', params: { first_name: 'Ghost' }.to_json, headers: headers

        expect(response).to have_http_status(:not_found)

        json = JSON.parse(response.body)
        expect(json['errors']).to include('User not found')
      end
    end

    context 'with invalid password confirmation' do
      it 'returns validation error (422)' do
        put "/api/v1/users/#{user.id}", params: {
          password: 'newpassword',
          password_confirmation: 'newpassword123'
        }.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json['errors']).to include("Password confirmation doesn't match Password")
      end
    end

    context 'with empty payload' do
      it 'returns 200 and does not change the user' do
        old_name = user.first_name

        put "/api/v1/users/#{user.id}", params: {}.to_json, headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['first_name']).to eq(old_name)
      end
    end
  end
end
