require 'rails_helper'

RSpec.describe "DELETE /api/v1/users/:id", type: :request do
  let!(:user_to_delete) { create(:user) }
  let!(:other_user) { create(:user) } # Added to ensure other records are not affected

  # --- Positive Test Cases ---

  describe 'when the user exists' do
    it 'decreases the user count by 1' do
      expect do
        delete "/api/v1/users/#{user_to_delete.id}"
      end.to change(User, :count).by(-1)
    end

    # Use a nested context for response-specific checks
    context 'the response for a successful deletion' do
      before { delete "/api/v1/users/#{user_to_delete.id}" }

      it 'returns a 200 OK status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns a success message' do
        json = JSON.parse(response.body)
        expect(json['message']).to eq('User deleted successfully')
      end

      it 'returns the response in JSON format' do
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    it 'deletes the correct user from the database' do
      delete "/api/v1/users/#{user_to_delete.id}"
      expect(User.find_by(id: user_to_delete.id)).to be_nil
    end

    it 'does not affect other users' do
      delete "/api/v1/users/#{user_to_delete.id}"
      expect(User.find_by(id: other_user.id)).not_to be_nil
    end
  end

  # --- Negative Test Cases ---

  describe 'when the user does not exist' do
    it 'does not change the user count' do
      expect do
        delete "/api/v1/users/999999"
      end.not_to change(User, :count)
    end

    it 'returns a 404 Not Found status' do
      delete "/api/v1/users/999999"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns a "User not found" error message' do
      delete "/api/v1/users/999999"
      json = JSON.parse(response.body)
      expect(json['errors']).to include('User not found')
    end
  end

  describe 'when the ID is invalid' do
    context 'with a non-numeric ID' do
      it 'returns a 404 Not Found status' do
        # 'abc'.to_i in the controller results in 0, leading to a "User not found" error
        delete "/api/v1/users/abc"
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with an ID of 0' do
      it 'returns a 404 Not Found status' do
        delete "/api/v1/users/0"
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('User not found')
      end
    end
  end
end
