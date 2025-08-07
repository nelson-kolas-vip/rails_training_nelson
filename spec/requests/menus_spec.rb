require 'rails_helper'

RSpec.describe "Menus", type: :request do
  let!(:restaurant) { create(:restaurant) }
  let!(:staff) { create(:staff_user) } # In case future auth is added

  describe "GET /restaurants/:restaurant_id/menus" do
    it "renders the index successfully" do
      get restaurant_menus_path(restaurant)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /restaurants/:restaurant_id/menus/new" do
    it "renders the new form successfully" do
      get new_restaurant_menu_path(restaurant)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /restaurants/:restaurant_id/menus" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          menu: {
            item_name: "Paneer Tikka",
            description: "Spicy grilled paneer",
            price: 12.50,
            category: "Indian",
            available: true,
            veg_status: "veg" # assuming enum { veg: 1, non_veg: 2 }
          }
        }
      end

      it "creates a new menu item" do
        expect do
          post restaurant_menus_path(restaurant), params: valid_params
        end.to change(Menu, :count).by(1)

        expect(response).to redirect_to(restaurant_menus_path(restaurant))
        follow_redirect!
        expect(response.body).to include("Menu item created.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          menu: {
            item_name: "", # Invalid
            description: "Tasty food",
            price: nil,
            category: "Italian",
            available: true,
            veg_status: "veg"
          }
        }
      end

      it "does not create a menu and re-renders the form" do
        post restaurant_menus_path(restaurant), params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("error", "can't be blank").or include("prohibited this menu from being saved")
      end
    end
  end

  describe "PATCH /restaurants/:restaurant_id/menus/:id" do
    let!(:menu) { create(:menu, restaurant: restaurant, item_name: "Old Dish") }

    context "with valid parameters" do
      let(:update_params) do
        {
          menu: {
            item_name: "New Dish"
          }
        }
      end

      it "updates the menu and redirects to index" do
        patch restaurant_menu_path(restaurant, menu), params: update_params
        expect(response).to redirect_to(restaurant_menus_path(restaurant))
        follow_redirect!
        expect(response.body).to include("New Dish item updated.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          menu: {
            item_name: ""
          }
        }
      end

      it "does not update the menu and re-renders the edit form" do
        patch restaurant_menu_path(restaurant, menu), params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("error").or include("can't be blank")
      end
    end
  end

  describe "DELETE /restaurants/:restaurant_id/menus/:id" do
    let!(:menu) { create(:menu, restaurant: restaurant) }

    it "deletes the menu and redirects to index" do
      expect do
        delete restaurant_menu_path(restaurant, menu)
      end.to change(Menu, :count).by(-1)

      expect(response).to redirect_to(restaurant_menus_path(restaurant))
      follow_redirect!
      expect(response.body).to include("Menu item deleted.")
    end
  end
end
