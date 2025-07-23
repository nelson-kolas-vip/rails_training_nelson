# spec/requests/avatars/update_spec.rb
require 'rails_helper'

RSpec.describe "AvatarsController", type: :request do
  let(:user) { create(:user, password: "password123") }

  before do
    post new_user_session_path, params: {
      user: {
        email: user.email,
        password: "password123"
      }
    }
  end

  describe "PATCH /avatar" do
    context "with a valid image file" do
      let(:image_path) { Rails.root.join("spec/fixtures/files/avatar.jpg") }
      let(:avatar_file) { fixture_file_upload(image_path, "image/jpg") }

      it "attaches the avatar and redirects" do
        patch "/avatar", params: { user: { avatar: avatar_file } }

        expect(response).to redirect_to(edit_avatar_path)
        follow_redirect!

        expect(response.body).to include("Avatar updated successfully.")
        expect(user.reload.avatar).to be_attached
      end
    end

    context "with an invalid file type" do
      let(:file_path) { Rails.root.join("spec/fixtures/files/invalid.txt") }
      let(:invalid_file) { fixture_file_upload(file_path, "text/plain") }

      it "does not attach the file and renders an error" do
        patch "/avatar", params: { user: { avatar: invalid_file } }

        expect(response).to redirect_to(edit_avatar_path)
        follow_redirect!
        expect(response.body).to include("Avatar must be a JPEG or PNG")
        expect(user.reload.avatar).not_to be_attached
      end
    end
  end
end
