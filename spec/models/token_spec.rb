require 'rails_helper'

RSpec.describe Token, type: :model do
  context 'when creating a new token' do
    let(:token) { Token.create }

    it 'is valid with all attributes generated automatically' do
      expect(token).to be_valid
    end

    it 'generates a secure token value before creation' do
      expect(token.value).not_to be_nil
      expect(token.value.length).to eq(64)
    end

    it 'sets an expiration date before creation' do
      expect(token.expired_at).not_to be_nil
    end

    it 'sets the expiration date to be in the future' do
      expect(token.expired_at).to be > Time.now
    end
  end
end
