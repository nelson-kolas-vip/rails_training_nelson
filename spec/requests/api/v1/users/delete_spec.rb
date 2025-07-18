require 'rails_helper'

RSpec.describe "DELETE /api/v1/users/:id", type: :request do
  let!(:user) { create(:user) }

  describe 'DELETE /api/v1/users/:id' do
    context 'when user exists' do
      it 'deletes the user and returns success message' do
        delete "/api/v1/users/#{user.id}"

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ 'message' => 'User deleted successfully' })
        expect(User.find_by(id: user.id)).to be_nil
      end
    end

    context 'when user does not exist' do
      it 'returns 404 with user not found message' do
        delete "/api/v1/users/999999"

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq({ 'errors' => ['User not found'] })
      end
    end

    context 'when ID is non-numeric' do
      it 'returns 404 not found' do
        delete "/api/v1/users/abc"

        expect(response).to have_http_status(:not_found)
      end
    end


    context 'when ID is blank' do
      it 'returns 404 error due to missing route' do
        delete "/api/v1/users/"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
