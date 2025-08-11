require 'rails_helper'

RSpec.describe "GET /api/v1/users with filters", type: :request do
  context "when filtering by first_name" do
    let!(:nelson1) { create(:user, first_name: "Nelson") }
    let!(:nelson2) { create(:user, first_name: "Nelson") }
    let!(:other)   { create(:user, first_name: "Samson") }

    it "returns users matching first_name" do
      get "/api/v1/users", params: { first_name: "Nelson" }
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      expect(json.map { |u| u["first_name"] }.uniq).to eq(["Nelson"])
    end
  end

  context "when filtering by last_name" do
    let!(:u1) { create(:user, last_name: "Doe") }
    let!(:u2) { create(:user, last_name: "Doe") }
    let!(:u3) { create(:user, last_name: "Norris") }

    it "returns users matching last_name" do
      get "/api/v1/users", params: { last_name: "Doe" }
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      expect(json.map { |u| u["last_name"] }.uniq).to eq(["Doe"])
    end
  end

  context "when filtering by email" do
    let!(:user1) { create(:user, email: "john@example.com") }
    let!(:user2) { create(:user, email: "jane@example.com") }

    it "returns user with exact email match" do
      get "/api/v1/users", params: { email: "john@example.com" }
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json.first["email"]).to eq("john@example.com")
    end
  end

  context "when filtering by multiple fields" do
    let!(:john_doe) { create(:user, first_name: "John", last_name: "Doe", email: "john@example.com") }
    let!(:john_milton) { create(:user, first_name: "John", last_name: "Milton", email: "milton@example.com") }

    it "returns users matching all fields" do
      get "/api/v1/users", params: { first_name: "John", last_name: "Doe" }
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json.first["first_name"]).to eq("John")
      expect(json.first["last_name"]).to eq("Doe")
    end
  end

  context "when filters return no results" do
    before { create(:user, first_name: "Alice") }

    it "returns an empty array" do
      get "/api/v1/users", params: { first_name: "Bob" }
      json = JSON.parse(response.body)
      expect(json).to eq([])
    end
  end

  context "with edge cases and negative filter scenarios" do
    let!(:user_case) { create(:user, first_name: "Peter", email: "PETER@EXAMPLE.COM") }

    it "is case-insensitive when filtering by first_name" do
      get "/api/v1/users", params: { first_name: "peter" }
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json.first['first_name']).to eq("Peter")
    end

    it "is case-insensitive when filtering by email" do
      get "/api/v1/users", params: { email: "peter@example.com" }
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json.first['email'].downcase).to eq("peter@example.com")
    end

    it "returns an empty array for conflicting filters" do
      get "/api/v1/users", params: { first_name: "Peter", last_name: "Jones" }
      json = JSON.parse(response.body)
      expect(json).to be_empty
    end

    it "ignores a filter for a non-existent attribute" do
      get "/api/v1/users", params: { non_existent_param: "some_value" }
      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json.size).to eq(User.count)
    end
  end
end
