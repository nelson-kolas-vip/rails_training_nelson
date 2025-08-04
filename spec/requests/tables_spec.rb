require 'rails_helper'

RSpec.describe TablesController, type: :request do
  let!(:staff_user) { FactoryBot.create(:staff_user) }
  let!(:restaurant) { FactoryBot.create(:restaurant, user: staff_user) }
  let!(:table) { FactoryBot.create(:table, restaurant: restaurant, table_number: 1, seating_capacity: 4) }

  describe "GET #index" do
    before { sign_in staff_user, scope: :user }

    context "when a staff user is signed in" do
      it "renders a successful response" do
        get restaurant_tables_path(restaurant)
        expect(response).to be_successful
        expect(response.body).to include("Tables for #{restaurant.name}")
      end
    end

    context "when a status filter is applied" do
      let!(:occupied_table) { FactoryBot.create(:table, restaurant: restaurant, status: :occupied) }

      it "only shows tables with the specified status" do
        get restaurant_tables_path(restaurant, status: "available")
        expect(response.body).to include("available")
      end
    end

    context "when a search query is provided" do
      let!(:table_with_99) { FactoryBot.create(:table, restaurant: restaurant, table_number: 99, seating_capacity: 8) }

      it "shows only matching tables" do
        get restaurant_tables_path(restaurant, search: "99")
        expect(response.body).to include("99")
      end
    end
  end

  describe "POST #create" do
    before { sign_in staff_user, scope: :user }

    context "with valid parameters" do
      it "creates a new table and redirects" do
        expect do
          post restaurant_tables_path(restaurant), params: { table: { table_number: 5, seating_capacity: 6, status: "available" } }
        end.to change(Table, :count).by(1)
        expect(response).to redirect_to(restaurant_tables_path(restaurant))
        follow_redirect!
        expect(response.body).to include("Table created successfully.")
      end
    end

    context "with invalid parameters" do
      it "does not create a new table and redirects with an error" do
        expect do
          post restaurant_tables_path(restaurant), params: { table: { table_number: nil, seating_capacity: nil } }
        end.to_not change(Table, :count)
        expect(response).to redirect_to(restaurant_tables_path(restaurant))
        follow_redirect!
        expect(response.body).to include("Failed to create table.")
      end
    end
  end

  describe "PATCH #update" do
    before { sign_in staff_user, scope: :user }

    context "with valid parameters" do
      it "updates the requested table" do
        patch restaurant_table_path(restaurant, table), params: { table: { seating_capacity: 8, status: "occupied" } }
        table.reload
        expect(table.seating_capacity).to eq(8)
        expect(table.occupied?).to be(true)
        expect(response).to redirect_to(restaurant_tables_path(restaurant))
        follow_redirect!
        expect(response.body).to include("Table updated successfully.")
      end
    end

    context "with invalid parameters" do
      it "does not update the table and redirects with an error" do
        original_seating_capacity = table.seating_capacity
        patch restaurant_table_path(restaurant, table), params: { table: { seating_capacity: nil } }
        table.reload
        expect(table.seating_capacity).to eq(original_seating_capacity)
        expect(response).to redirect_to(restaurant_tables_path(restaurant))
        follow_redirect!
        expect(response.body).to include("Failed to update table.")
      end
    end
  end

  describe "DELETE #destroy" do
    before { sign_in staff_user, scope: :user }

    context "when the table exists" do
      it "destroys the table and redirects" do
        expect do
          delete restaurant_table_path(restaurant, table)
        end.to change(Table, :count).by(-1)
        expect(response).to redirect_to(restaurant_tables_path(restaurant))
        follow_redirect!
        expect(response.body).to include("Table deleted successfully.")
      end
    end
  end
end
