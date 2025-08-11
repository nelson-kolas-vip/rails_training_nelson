require 'rails_helper'

RSpec.describe 'PUT /api/v1/users/:id', type: :request do
  # Ensure the user is created with all required attributes to avoid nil values.
  let!(:user) { create(:user, first_name: 'John', email: 'john.doe@example.com', age: 30, date_of_birth: '1994-01-20') }
  let!(:another_user) { create(:user, email: 'jane.doe@example.com') }
  let(:headers) { { 'Content-Type': 'application/json' } }

  # A base set of attributes to satisfy the API's requirement for a full parameter list.
  # We will merge specific changes for each test into this hash.
  let(:base_attributes) do
    {
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      phone_number: user.phone_number,
      password: 'password123', # A dummy password for validation purposes
      password_confirmation: 'password123',
      age: user.age,
      date_of_birth: user.date_of_birth.to_s
    }
  end

  # --- Positive Test Cases ---
  describe 'with valid parameters' do
    context 'when updating multiple fields' do
      let(:update_params) { base_attributes.merge(first_name: 'Johnny', last_name: 'Doer') }

      it 'updates the user and returns a 200 OK status' do
        put "/api/v1/users/#{user.id}", params: update_params.to_json, headers: headers

        expect(response).to have_http_status(:ok)
        user.reload
        expect(user.first_name).to eq('Johnny')
        expect(user.last_name).to eq('Doer')
      end

      it 'returns the updated user data' do
        put "/api/v1/users/#{user.id}", params: update_params.to_json, headers: headers
        json = JSON.parse(response.body)
        expect(json['first_name']).to eq('Johnny')
      end
    end

    context 'when updating a single field' do
      it 'updates only that field and returns the updated user' do
        update_params = base_attributes.merge(first_name: 'Jonathan')
        put "/api/v1/users/#{user.id}", params: update_params.to_json, headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['first_name']).to eq('Jonathan')
        expect(json['email']).to eq(user.email) # Email should be unchanged
      end
    end

    context 'when updating the password correctly' do
      let(:password_params) { base_attributes.merge(password: 'newSecurePassword123', password_confirmation: 'newSecurePassword123') }
      it 'updates the user password and returns 200 OK' do
        put "/api/v1/users/#{user.id}", params: password_params.to_json, headers: headers
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # --- Negative Test Cases ---
  describe 'with invalid parameters' do
    context 'when the user ID is invalid' do
      it 'returns a 404 Not Found status' do
        put '/api/v1/users/99999', params: base_attributes.to_json, headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it 'returns a "User not found" error message' do
        put '/api/v1/users/99999', params: base_attributes.to_json, headers: headers
        json = JSON.parse(response.body)
        expect(json['errors']).to include('User not found')
      end
    end

    context 'when email is invalid' do
      it 'returns a 422 Unprocessable Entity status' do
        update_params = base_attributes.merge(email: 'not-an-email')
        put "/api/v1/users/#{user.id}", params: update_params.to_json, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when email is already taken by another user' do
      it 'returns a 422 Unprocessable Entity status' do
        update_params = base_attributes.merge(email: another_user.email)
        put "/api/v1/users/#{user.id}", params: update_params.to_json, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Email has already been taken')
      end
    end

    context 'when password confirmation does not match' do
      let(:invalid_password_params) { base_attributes.merge(password: 'newPassword', password_confirmation: 'wrongConfirmation') }
      it 'returns a 422 Unprocessable Entity status' do
        put "/api/v1/users/#{user.id}", params: invalid_password_params.to_json, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Password confirmation doesn't match Password")
      end
    end
  end
end
