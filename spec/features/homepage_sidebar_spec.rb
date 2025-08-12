require 'rails_helper'

RSpec.describe "Homepage Sidebar", type: :feature, js: true do
  # We need a logged-in user to see the sidebar
  let(:user) { create(:user) }

  before do
    # NOTE: The login_as method requires the Warden test helpers.
    # Ensure you have `config.include Warden::Test::Helpers` in your rails_helper.rb
    login_as(user, scope: :user)
    visit root_path
    # A good practice is to confirm the user is actually logged in.
    # We check for the user's first name in the navbar instead of the hidden "Sign Out" button.
    expect(page).to have_content(user.first_name)
  end

  describe "Sidebar Accordion Functionality" do
    before do
      # The sidebar is initially hidden, so we need to click the hamburger icon to open it
      find('a[data-bs-target="#sidebarMenu"]').click
      # Wait for the offcanvas to be fully visible
      expect(page).to have_selector('#sidebarMenu.show')
    end

    context "when clicking the 'My Profile' dropdown" do
      it "opens and closes the profile section" do
        # Initially, the profile links should not be visible
        expect(page).not_to have_link('Update Avatar')
        expect(page).not_to have_link('Update Personal Data')
      end
    end

    context "when clicking the 'Restaurants' dropdown" do
      it "opens and closes the restaurants section" do
        # Initially, the restaurant links should not be visible
        expect(page).not_to have_link('Restaurants')
        expect(page).not_to have_link('Create Restaurant')
      end
    end
  end
end
