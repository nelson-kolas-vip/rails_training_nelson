require 'rails_helper'

RSpec.describe "Menus", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/menu/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/menu/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/menu/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/menu/destroy"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/menu/update"
      expect(response).to have_http_status(:success)
    end
  end

end
