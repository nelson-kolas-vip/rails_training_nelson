require 'rails_helper'

RSpec.describe "AvatarsController", type: :request do
  let(:user) { create(:user, password: "password123", password_confirmation: "password123") }

  before do
    post user_session_path, params: {
      user: {
        email: user.email,
        password: "password123"
      }
    }

    expect(response).to have_http_status(:see_other)
    follow_redirect!
  end

  describe "PATCH /avatar" do
    let(:valid_avatar) { fixture_file_upload(Rails.root.join("spec/fixtures/files/avatar.jpg"), "image/jpeg") }
    let(:invalid_file) { fixture_file_upload(Rails.root.join("spec/fixtures/files/invalid.txt"), "text/plain") }

    context "with a valid image file" do
      it "attaches the avatar and shows a success notice" do
        patch "/avatar", params: { user: { avatar: valid_avatar } }

        expect(response).to redirect_to(edit_avatar_path)
        follow_redirect!

        expect(response.body).to include("Avatar updated successfully.")
        expect(user.reload.avatar).to be_attached
      end
    end

    context "when no file is submitted" do
      it "redirects with a success notice without attaching a file" do
        patch "/avatar", params: { user: { avatar: nil } }

        expect(response).to redirect_to(edit_avatar_path)
        follow_redirect!
        expect(response.body).to include("Avatar updated successfully.")
        expect(user.reload.avatar).not_to be_attached
      end
    end
  end

  describe "DELETE /avatar" do
    before do
      user.avatar.attach(fixture_file_upload(Rails.root.join("spec/fixtures/files/avatar.jpg"), "image/jpeg"))
      user.save!
    end

    it "deletes the user's avatar" do
      expect(user.reload.avatar).to be_attached

      delete "/avatar"

      expect(response).to redirect_to(edit_avatar_path)
      follow_redirect!
      expect(response.body).to include("Avatar deleted.")
      expect(user.reload.avatar).not_to be_attached
    end
  end
end
