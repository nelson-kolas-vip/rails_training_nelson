require 'rails_helper'

RSpec.describe "restaurants/new.html.erb", type: :view do
  context "when rendering the form for a new restaurant" do
    before do
      # The controller's 'new' action assigns a new Restaurant instance
      assign(:restaurant, Restaurant.new)
      render
    end

    it "displays the 'Create Restaurant' heading" do
      expect(rendered).to match(/Create Restaurant/)
    end

    it "renders the restaurant form and all its fields" do
      # Check that the form tag exists and posts to the correct path
      expect(rendered).to have_selector("form[action='#{restaurants_path}'][method='post']")

      # Check for the presence of all form fields
      expect(rendered).to have_field("restaurant[name]")
      expect(rendered).to have_field("restaurant[description]")
      expect(rendered).to have_field("restaurant[location]")
      expect(rendered).to have_field("restaurant[cuisine_type]")
    end

    it "displays the 'Create Restaurant' submit button" do
      expect(rendered).to have_button("Create Restaurant")
    end

    it "does not display an error message box" do
      expect(rendered).not_to have_selector(".alert-danger")
    end
  end

  context "when re-rendering the form with validation errors" do
    before do
      # Simulate a failed creation by creating a restaurant with errors
      restaurant = Restaurant.new
      restaurant.valid? # This triggers the validation and adds errors
      assign(:restaurant, restaurant)
      render
    end

    it "displays the error messages container" do
      expect(rendered).to have_selector(".alert-danger")
      expect(rendered).to match(/Please fix the following errors:/)
    end
  end
end
