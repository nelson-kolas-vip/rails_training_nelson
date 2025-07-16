require 'rails_helper'

RSpec.describe "API::V1::Users", type: :request do
  describe "GET /api/v1/users" do
    context "when users exist" do
      before do
        create_list(:user, 5)
        get "/api/v1/users"
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
      before { get "/api/v1/users" }

      it "returns an empty array" do
        json = JSON.parse(response.body)
        expect(json).to eq([])
      end

      it "still returns a success status" do
        expect(response).to have_http_status(:success)
      end
    end

    context "when the route is invalid" do
      it "returns 404 Not Found" do
        get "/api/v1/non_existent_route"
        expect(response).to have_http_status(:not_found)
      end
    end

    # context "when a request method is not allowed" do
    #   it "returns 405 Method Not Allowed (if restricted)" do
    #     expect do
    #       post "/api/v1/users"
    #     end.to raise_error(ActionController::RoutingError).or(change {
    #       response.status
    #     })
    #   end
    # end

    # context "when unauthorized access is restricted (if auth is added)" do
    #   it "returns 401 Unauthorized (if authentication required)" do
    #     skip("Add this test when auth is implemented")
    #   end
    # end
  end
end
