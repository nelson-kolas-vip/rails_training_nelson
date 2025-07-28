require 'rails_helper'

RSpec.describe "RestaurantsController#index", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  context "when there are no restaurants" do
    it "renders the index page with no restaurant message" do
      get restaurants_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("No restaurants found")
    end
  end

  context "when there are restaurants" do
    let!(:restaurant1) { create(:restaurant, name: "Tandoori Palace", user: user) }
    let!(:restaurant2) { create(:restaurant, name: "Pasta Heaven", user: user) }

    it "renders the index page with restaurant cards" do
      get restaurants_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Tandoori Palace")
      expect(response.body).to include("Pasta Heaven")
    end

    it "displays location, cuisine, and description" do
      get restaurants_path
      expect(response.body).to include(restaurant1.location)
      expect(response.body).to include(restaurant1.cuisine_type)
      expect(response.body).to include(restaurant2.description.truncate(100))
    end
  end

  context "when user is not signed in" do
    before do
      sign_out user
    end

    it "redirects to login page" do
      get restaurants_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
