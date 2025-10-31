require 'rails_helper'

RSpec.describe "User Registration", type: :request do
  describe "POST /users" do
    it "registers with valid data" do
      user_attributes = attributes_for(:user)

      expect do
        post user_registration_path, params: { user: user_attributes }
      end.to change(User, :count).by(1)

      expect(response).to redirect_to(homepage_path)
    end

    it "does not register with invalid email" do
      user_attributes = attributes_for(:user, email: "")

      expect do
        post user_registration_path, params: { user: user_attributes }
      end.not_to change(User, :count)

      expect(response.body).to match(/Email can.*blank/i)
    end
  end
end
