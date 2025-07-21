require 'rails_helper'

RSpec.describe "GET /api/v1/users", type: :request do
  let!(:token) { Token.create }

  context "when users exist" do
    before do
      create_list(:user, 5)
      get "/api/v1/users", headers: { "Authorization" => token.value }
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns a list of users" do
      json = JSON.parse(response.body)
      expect(json.length).to eq(5)
    end

    it "returns users with only allowed attributes" do
      json = JSON.parse(response.body)
      user = json.first
      expect(user.keys).to match_array(%w[id first_name last_name email created_at])
    end

    it "returns data in JSON format" do
      expect(response.content_type).to eq("application/json; charset=utf-8")
    end

    it "does not return sensitive attributes" do
      json = JSON.parse(response.body)
      user = json.first
      expect(user.keys).not_to include("password", "encrypted_password", "updated_at")
    end
  end

  context "when no users exist" do
    before { get "/api/v1/users", headers: { "Authorization" => token.value } }

    it "returns an empty array" do
      json = JSON.parse(response.body)
      expect(json).to eq([])
    end

    it "still returns a success status" do
      expect(response).to have_http_status(:success)
    end
  end

  context "when authorization is missing or invalid" do
    it "returns unauthorized status with no token" do
      get "/api/v1/users"
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["error"]).to eq("Unauthorized")
    end

    it "returns unauthorized with invalid token" do
      get "/api/v1/users", headers: { "Authorization" => "invalidtoken123" }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["error"]).to eq("Unauthorized")
    end
  end

  context "when route is invalid" do
    it "returns 404 Not Found" do
      get "/api/v1/non_existent_route", headers: { "Authorization" => token.value }
      expect(response).to have_http_status(:not_found)
    end
  end
end
