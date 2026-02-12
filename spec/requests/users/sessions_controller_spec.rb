require 'rails_helper'

RSpec.describe Users::SessionsController, type: :request do
  let(:password) { 'rails@123' }

  let!(:admin_user)    { create(:user, email: 'admin@example.com', password:, role_type: :admin) }
  let!(:staff_user)    { create(:user, email: 'staff@example.com', password:, role_type: :staff) }
  let!(:customer_user) { create(:user, email: 'customer@example.com', password:, role_type: :customer) }

  describe 'GET /users/sign_in' do
    it 'redirects to root if role is missing' do
      get new_user_session_path
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include('Role is required to sign in.')
    end

    it 'redirects to root if role is invalid' do
      get new_user_session_path(role: 'manager')
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include('Role is required to sign in.')
    end

    it 'renders login page when role is valid' do
      get new_user_session_path(role: 'admin')
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Log in')
    end
  end

  describe 'POST /users/sign_in' do
    context 'with missing role' do
      it 'redirects to root path' do
        post user_session_path, params: {
          user: { email: admin_user.email, password: }
        }
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('Role is required to sign in.')
      end
    end

    context 'with valid credentials and correct role' do
      it 'logs in successfully' do
        post user_session_path(role: 'admin'), params: {
          user: { email: admin_user.email, password: }
        }
        expect(response).to redirect_to(root_path) # default Devise behavior unless overridden
        follow_redirect!
        expect(controller.current_user).to eq(admin_user)
      end
    end

    context 'with valid credentials but wrong role' do
      it 'redirects to correct portal with alert' do
        post user_session_path(role: 'staff'), params: {
          user: { email: admin_user.email, password: }
        }
        expect(response).to redirect_to(new_user_session_path(role: 'staff'))
        follow_redirect!
        expect(response.body).to include("You are not authorized to log in from this portal.")
      end
    end

    context 'with incorrect password' do
      it 'fails to log in' do
        post user_session_path(role: 'admin'), params: {
          user: { email: admin_user.email, password: 'wrongpass' }
        }
        expect(response.body).to include('Invalid Email or password')
        expect(controller.current_user).to be_nil
      end
    end

    context 'with non-existent user' do
      it 'shows invalid login message' do
        post user_session_path(role: 'admin'), params: {
          user: { email: 'nouser@example.com', password: 'anything' }
        }
        expect(response.body).to include('Invalid Email or password')
      end
    end
  end
end
