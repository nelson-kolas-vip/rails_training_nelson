require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = build(:user)
    expect(user).to be_valid
  end

  it "is invalid without an email" do
    user = build(:user, email: nil)
    expect(user).not_to be_valid
  end

  it "is invalid without a password" do
    user = build(:user, password: nil)
    expect(user).not_to be_valid
  end

  it "is invalid with mismatched password confirmation" do
    user = build(:user, password_confirmation: "wrongpass")
    expect(user).not_to be_valid
  end

  it "is invalid with a duplicate email" do
    create(:user, email: "test@example.com")
    user = build(:user, email: "test@example.com")
    expect(user).not_to be_valid
  end
end
