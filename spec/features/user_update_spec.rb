require 'rails_helper'

RSpec.describe "User Profile Update", type: :request do
  let(:user) { create(:user, password: "rails@123", password_confirmation: "rails@123") }

  before do
    new_user_session_path user
  end

  describe "PATCH /users" do
    let(:valid_params) do
      {
        user: {
          first_name: "Updated",
          last_name: "User",
          email: "updated@example.com",
          phone_number: "9998887777",
          age: 30,
          date_of_birth: "1995-01-01",
          current_password: "rails@123"
        }
      }
    end

    it "updates the profile with valid data and correct password" do
      patch user_registration_path, params: valid_params

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Updated")
    end

    it "does not update without current password" do
      invalid_params = valid_params.deep_merge(user: { current_password: "" })
      patch user_registration_path, params: invalid_params

      expect(response.body).to include("Current password can't be blank")
    end

    it "does not update with incorrect current password" do
      invalid_params = valid_params.deep_merge(user: { current_password: "wrongpass" })
      patch user_registration_path, params: invalid_params

      expect(response.body).to include("Current password is invalid")
    end

    it "does not update with invalid email" do
      invalid_params = valid_params.deep_merge(user: { email: "invalid@", current_password: "rails@123" })
      patch user_registration_path, params: invalid_params

      expect(response.body).to include("Email is invalid")
    end

    it "does not update with non-numeric age" do
      invalid_params = valid_params.deep_merge(user: { age: "abc", current_password: "rails@123" })
      patch user_registration_path, params: invalid_params

      expect(response.body).to include("Age is not a number")
    end
  end
end
