require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = build(:user)
    expect(user).to be_valid
  end

  it "is invalid without a first_name" do
    user = build(:user, first_name: nil)
    expect(user).to_not be_valid
  end

  it "is invalid without an email" do
    user = build(:user, email: nil)
    expect(user).to_not be_valid
  end

  it "is invalid without a password" do
    user = build(:user, password: nil)
    expect(user).to_not be_valid
  end
end
