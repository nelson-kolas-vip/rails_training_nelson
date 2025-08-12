require 'rails_helper'

RSpec.describe "avatars/edit.html.erb", type: :view do
  let(:user) { create(:user) }

  before do
    # Devise's helpers are needed for `current_user` to work in the view
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:user_signed_in?).and_return(true)
  end

  context "when the user does not have an avatar" do
    before do
      render
    end

    it "displays the 'No Avatar Uploaded' message" do
      expect(rendered).to match(/No Avatar Uploaded/)
    end

    it "shows the default avatar image" do
      # This selector is more resilient to asset digests (e.g., def-a1b2c3.jpg)
      # It checks that the src attribute starts with the path to the default image.
      expect(rendered).to have_selector("img[src^='/assets/def']")
    end

    it "displays the file upload form" do
      expect(rendered).to have_selector("form[action='#{avatar_path}']")
      expect(rendered).to have_field("user[avatar]")
      expect(rendered).to have_button("Upload Avatar")
    end

    it "does not show the 'Delete Avatar' button" do
      expect(rendered).not_to have_button("Delete Avatar")
    end
  end

  context "when the user has an avatar" do
    before do
      # Attach a dummy file to the user's avatar
      file_path = Rails.root.join("spec/fixtures/files/avatar.jpg")
      user.avatar.attach(io: File.open(file_path), filename: 'avatar.jpg', content_type: 'image/jpeg')
      render
    end

    it "displays the 'Current Avatar:' message" do
      expect(rendered).to match(/Current Avatar:/)
    end

    it "shows the user's current avatar" do
      # We check for a part of the Active Storage URL path
      expect(rendered).to have_selector("img[src*='avatar.jpg']")
    end

    it "shows the 'Delete Avatar' button" do
      expect(rendered).to have_button("Delete Avatar")
    end
  end
end
