require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  let(:user) { create(:user) }
  context "with valid attributes" do
    it "is valid when all required fields are present" do
      restaurant = build(:restaurant, user: user)
      expect(restaurant).to be_valid
    end

    it "has an initial status of 'open'" do
      restaurant = create(:restaurant, user: user)
      expect(restaurant.status).to eq("open")
    end
  end
  context "with invalid attributes" do
    it "is invalid without a name" do
      restaurant = build(:restaurant, name: nil, user: user)
      expect(restaurant).not_to be_valid
      expect(restaurant.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a description" do
      restaurant = build(:restaurant, description: nil, user: user)
      expect(restaurant).not_to be_valid
      expect(restaurant.errors[:description]).to include("can't be blank")
    end

    it "is invalid without a location" do
      restaurant = build(:restaurant, location: nil, user: user)
      expect(restaurant).not_to be_valid
      expect(restaurant.errors[:location]).to include("can't be blank")
    end

    it "is invalid without a cuisine_type" do
      restaurant = build(:restaurant, cuisine_type: nil, user: user)
      expect(restaurant).not_to be_valid
      expect(restaurant.errors[:cuisine_type]).to include("can't be blank")
    end
  end

  context "without a user association" do
    it "is invalid" do
      restaurant = build(:restaurant, user: nil)
      expect(restaurant).not_to be_valid
      expect(restaurant.errors[:user]).to include("must exist")
    end
  end
end
