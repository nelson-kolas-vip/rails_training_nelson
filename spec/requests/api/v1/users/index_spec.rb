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

    context "when filtering by first_name" do
      let!(:nelson_doe)   { create(:user, first_name: "Nelson", last_name: "Rodrigues", email: "nelson@example.com") }
      let!(:nelson_singh) { create(:user, first_name: "Nelson", last_name: "Singh", email: "nelson2@example.com") }
      let!(:samson_milton) { create(:user, first_name: "Samson", last_name: "Milton", email: "samson@example.com") }
      let!(:velson_doe) { create(:user, first_name: "Velson", last_name: "Doe", email: "velson@example.com") }

      it "returns users with matching first_name" do
        get "/api/v1/users", params: { first_name: "Nelson" }

        json = JSON.parse(response.body)
        expect(json.size).to eq(2)
        expect(json.map { |u| u["first_name"] }.uniq).to eq(["Nelson"])
      end
    end

    context "when filtering by last_name" do
      let!(:nelson_doe)   { create(:user, first_name: "Nelson", last_name: "Doe") }
      let!(:samson_doe)   { create(:user, first_name: "Samson", last_name: "Doe") }
      let!(:velson_norris) { create(:user, first_name: "Velson", last_name: "Norris") }

      it "returns users with matching last_name" do
        get "/api/v1/users", params: { last_name: "Doe" }

        json = JSON.parse(response.body)
        expect(json.size).to eq(2)
        expect(json.map { |u| u["last_name"] }.uniq).to eq(["Doe"])
      end
    end

    context "when filtering by email" do
      let!(:john) { create(:user, email: "john@example.com") }
      let!(:jane) { create(:user, email: "jane@example.com") }

      it "returns user with exact email match" do
        get "/api/v1/users", params: { email: "john@example.com" }

        json = JSON.parse(response.body)
        expect(json.size).to eq(1)
        expect(json.first["email"]).to eq("john@example.com")
      end
    end

    context "when filtering by multiple fields" do
      let!(:john_doe)    { create(:user, first_name: "John", last_name: "Doe", email: "john@example.com") }
      let!(:john_milton) { create(:user, first_name: "John", last_name: "Milton", email: "milton@example.com") }

      it "returns users that match all filters" do
        get "/api/v1/users", params: { first_name: "John", last_name: "Doe" }

        json = JSON.parse(response.body)
        expect(json.size).to eq(1)
        expect(json.first["first_name"]).to eq("John")
        expect(json.first["last_name"]).to eq("Doe")
      end
    end

    context "when filter returns no results" do
      before { create(:user, first_name: "Alice", last_name: "Smith", email: "alice@example.com") }

      it "returns an empty array" do
        get "/api/v1/users", params: { first_name: "Bob" }

        json = JSON.parse(response.body)
        expect(json).to eq([])
      end
    end
  end
end
