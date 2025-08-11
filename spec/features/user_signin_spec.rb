require 'rails_helper'

RSpec.describe "User Sign In", type: :feature do
  let!(:user) { create(:user, password: "rails@123") }

  it "logs in with correct credentials" do
    visit new_user_session_path

    fill_in "Email", with: user.email
    fill_in "Password", with: "rails@123"

    click_button "Sign In"

    expect(page).to have_content("Welcome back,")
  end

  it "shows error with incorrect credentials" do
    visit new_user_session_path

    fill_in "Email", with: user.email
    fill_in "Password", with: "wrongpass"

    click_button "Sign In"
    expect(page).to have_content(/Invalid email or password/i)
  end
end
