require 'rails_helper'

RSpec.describe "User Sign In", type: :feature do
  let!(:user) { create(:user, password: "secure123") }

  it "logs in with correct credentials" do
    visit sign_in_path

    fill_in "Email", with: user.email
    fill_in "Password", with: "secure123"

    click_button "Sign In"

    expect(page).to have_content("Welcome")
  end

  it "shows error with incorrect credentials" do
    visit sign_in_path

    fill_in "Email", with: user.email
    fill_in "Password", with: "wrongpass"

    click_button "Sign In"

    expect(page).to have_content("Invalid email or password")
  end
end
