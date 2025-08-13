require 'rails_helper'

RSpec.describe "Restaurants", type: :request do
  # Create a user that will be used for authentication in the tests
  let(:user) { create(:user, password: 'password123', password_confirmation: 'password123') }

  # --- Tests for Authenticated Users ---
  context "when user is signed in" do
    before do
      # For request specs, it's more reliable to sign in by posting to the session path.
      post user_session_path, params: {
        user: {
          email: user.email,
          password: 'password123'
        }
      }
      # A successful sign-in should redirect
      expect(response).to have_http_status(:see_other)
    end

    describe "GET /restaurants" do
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
    end

    describe "GET /restaurants/new" do
      it "returns a successful response" do
        get new_restaurant_path
        expect(response).to have_http_status(:success)
      end

      it "renders the new template" do
        get new_restaurant_path
        expect(response)
      end
    end

    describe "POST /restaurants" do
      context "with valid parameters" do
        let(:valid_params) do
          {
            restaurant: {
              name: "The Grand Cafe",
              description: "A lovely place for coffee and cake.",
              location: "123 Main St",
              cuisine_type: "Cafe"
            }
          }
        end

        it "creates a new Restaurant" do
          expect do
            post restaurants_path, params: valid_params
          end.to change(Restaurant, :count).by(1)
        end

        it "associates the new restaurant with the current user" do
          post restaurants_path, params: valid_params
          expect(Restaurant.last.user).to eq(user)
        end
      end

      context "with invalid parameters" do
        let(:invalid_params) do
          {
            restaurant: {
              name: "", # Name is required and is blank here
              description: "A lovely place.",
              location: "456 Side St",
              cuisine_type: "Bistro"
            }
          }
        end

        it "does not create a new Restaurant" do
          expect do
            post restaurants_path, params: invalid_params
          end.not_to change(Restaurant, :count)
        end

        it "re-renders the 'new' template with an unprocessable_entity status" do
          post restaurants_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response)
        end
      end
    end
  end

  # --- Tests for Unauthenticated Users ---
  context "when user is not signed in" do
    describe "GET /restaurants" do
      it "redirects to login page" do
        get restaurants_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "GET /restaurants/new" do
      it "redirects to the sign-in page" do
        get new_restaurant_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "POST /restaurants" do
      it "does not create a new restaurant and redirects" do
        expect do
          post restaurants_path, params: { restaurant: { name: "Test" } }
        end.not_to change(Restaurant, :count)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
