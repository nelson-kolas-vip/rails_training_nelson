require 'rails_helper'

RSpec.describe "User Sessions", type: :request do
  let(:user) { create(:user) }

  describe "POST /users/sign_in" do
    it "logs in with valid credentials" do
      post user_session_path, params: {
        user: { email: user.email, password: 'password123' }
      }
    end

    it "does not log in with invalid password" do
      post user_session_path, params: {
        user: { email: user.email, password: 'wrongpass' }
      }
      expect(response.body).to include("Invalid Email or password")
    end
  end
end
