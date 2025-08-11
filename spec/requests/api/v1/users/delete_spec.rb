require 'rails_helper'

RSpec.describe "DELETE /api/v1/users/:id", type: :request do
  let!(:user_to_delete) { create(:user) }
  let!(:other_user) { create(:user) }
  # Create a token to be used for authorization
  let!(:token) { create(:token) }
  let(:auth_headers) { { 'Authorization' => token.value } }

  describe 'when the user exists' do
    it 'decreases the user count by 1' do
      expect do
        delete "/api/v1/users/#{user_to_delete.id}", headers: auth_headers
      end.to change(User, :count).by(-1)
    end

    context 'the response for a successful deletion' do
      before { delete "/api/v1/users/#{user_to_delete.id}", headers: auth_headers }

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
      delete "/api/v1/users/#{user_to_delete.id}", headers: auth_headers
      expect(User.find_by(id: user_to_delete.id)).to be_nil
    end

    it 'does not affect other users' do
      delete "/api/v1/users/#{user_to_delete.id}", headers: auth_headers
      expect(User.find_by(id: other_user.id)).not_to be_nil
    end
  end

  describe 'when the user does not exist' do
    it 'does not change the user count' do
      expect do
        delete "/api/v1/users/999999", headers: auth_headers
      end.not_to change(User, :count)
    end

    it 'returns a 404 Not Found status' do
      delete "/api/v1/users/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns a "User not found" error message' do
      delete "/api/v1/users/999999", headers: auth_headers
      json = JSON.parse(response.body)
      expect(json['errors']).to include('User not found')
    end
  end
end
