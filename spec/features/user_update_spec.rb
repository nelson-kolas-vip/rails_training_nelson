require 'rails_helper'
RSpec.feature "User Profile Edit Page", type: :feature, js: true do
  let(:user) { create(:user, password: "rails@123", password_confirmation: "rails@123") }

  before do
    login_as(user, scope: :user)
    visit edit_user_registration_path
  end

  describe "the page content" do
    it "displays all the required form fields and buttons" do
      expect(page).to have_content("Edit Profile")
      expect(page).to have_field("First name")
      expect(page).to have_field("Last name")
      expect(page).to have_field("Email")
      expect(page).to have_field("Phone number")
      expect(page).to have_field("Age")
      expect(page).to have_field("Date of birth")
      expect(page).to have_field("Current password")
      expect(page).to have_button("Update Profile")
      expect(page).to have_link("Back to Dashboard")
    end
  end

  describe "form submission with invalid data" do
    it "shows an error if the current password is incorrect" do
      fill_in "First name", with: "New Name"
      fill_in "Current password", with: "wrongpassword"
      click_button "Update Profile"
    end

    it "shows an error if the email is invalid" do
      fill_in "Email", with: "not-an-email"
      fill_in "Current password", with: "rails@123"
      click_button "Update Profile"
    end

    it "shows an error if a required field is left blank" do
      fill_in "First name", with: ""
      fill_in "Current password", with: "rails@123"
      click_button "Update Profile"
    end
  end
end
