require 'rails_helper'

RSpec.describe "Tables Management", type: :request do
  let!(:staff_user) { User.create(email: "staff@example.com", password: "password123", role_type: :staff, status: :active) }
  let!(:restaurant) { Restaurant.create(name: "Cafe Code", location: "NY", cuisine_type: "Italian", rating: 4.2, status: :open, user: staff_user) }

  describe "GET /restaurants/:restaurant_id/tables" do
    context "when restaurant exists and staff is signed in" do
      before do
        sign_in staff_user, scope: :user
      end

      it "renders the index page with success" do
        get restaurant_tables_path(restaurant)
        expect(response).to have_http_status(:ok)

        expect(response.body).to include("Tables for #{restaurant.name}")
      end
    end

    context "when restaurant does not exist" do
      it "returns 404 error" do
        expect do
          get restaurant_tables_path(99_999)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when user is not signed in" do
      before do
        sign_out staff_user
      end

      it "redirects to staff login page" do
        get restaurant_tables_path(restaurant)
        expect(response).to redirect_to(new_user_session_path(role: 'staff'))
      end
    end
  end

  describe "POST /restaurants/:restaurant_id/tables" do
    context "with valid parameters" do
      before do
        sign_in staff_user, scope: :user
      end

      it "creates a new table and redirects" do
        expect do
          post restaurant_tables_path(restaurant), params: {
            table: {
              table_number: "T101",
              seating_capacity: 4,
              status: "available"
            }
          }
        end.to change(Table, :count).by(1)

        expect(response).to redirect_to(restaurant_tables_path(restaurant))
        follow_redirect!
        expect(response.body).to include("Table created successfully.")
      end
    end

    context "with invalid parameters" do
      before do
        sign_in staff_user, scope: :user
      end

      it "does not create a table and re-renders the form" do
        expect do
          post restaurant_tables_path(restaurant), params: {
            table: {
              table_number: "",
              seating_capacity: nil
            }
          }
        end.not_to change(Table, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Failed to create table.")
      end
    end
  end

  describe "Search functionality (UI dynamic search)" do
    before do
      sign_in staff_user, scope: :user
      Table.create!(table_number: "T201", seating_capacity: 6, status: "available", restaurant: restaurant)
      Table.create!(table_number: "T202", seating_capacity: 4, status: "occupied", restaurant: restaurant)
    end

    it "returns matching records for partial search query" do
      get restaurant_tables_path(restaurant), params: { search: "201" }
      expect(response.body).to include("T201")
      expect(response.body).not_to include("T202")
    end

    it "returns no records if no match found" do
      get restaurant_tables_path(restaurant), params: { search: "xyz" }
      expect(response.body).to include("No results found")
    end
  end
end
