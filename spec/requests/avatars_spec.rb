require 'rails_helper'

RSpec.describe "Avatars", type: :request do
  describe "GET /edit" do
    it "returns http success" do
      get "/avatars/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/avatars/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/avatars/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
