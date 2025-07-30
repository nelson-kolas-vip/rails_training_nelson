require 'rails_helper'

RSpec.describe "User Signup", type: :feature do
  it "allows a user to sign up with valid data" do
    visit new_user_registration_path

    fill_in "First name", with: "Nelson"
    fill_in "Last name", with: "Kolas"
    fill_in "Email", with: "nelson@example.com"
    fill_in "Password", with: "rails@123"

    fill_in "Password confirmation", with: "rails@123"
    fill_in "Age", with: 25
    fill_in "Date of birth", with: "2000-01-01"
    fill_in "Phone number", with: "1234567890"

    click_button "Sign Up"

    expect(page).to have_content(/Welcome back,/i)
  end

  it "shows errors with invalid data" do
    visit new_user_registration_path
    click_button "Sign Up"
    expect(page).to have_content("can't be blank")
  end
end
