require 'rails_helper'

RSpec.describe 'GET /api/v1/users', type: :request do
  # Create a set of users with distinct attributes for effective filter testing
  let!(:user1) { create(:user, first_name: 'John', last_name: 'Doe', email: 'john.doe@example.com') }
  let!(:user2) { create(:user, first_name: 'Jane', last_name: 'Smith', email: 'jane.smith@example.com') }
  let!(:user3) { create(:user, first_name: 'Johnny', last_name: 'Rocket', email: 'johnny.r@example.com') }

  context 'without any filters' do
    it 'returns all users' do
      get '/api/v1/users'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(3)
    end
  end

  context 'with filters' do
    it 'filters by first_name (partial match)' do
      get '/api/v1/users', params: { first_name: 'John' }
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      expect(json.map { |u| u['id'] }).to contain_exactly(user1.id, user3.id)
    end

    it 'filters by last_name (exact match)' do
      get '/api/v1/users', params: { last_name: 'Smith' }
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json.first['id']).to eq(user2.id)
    end

    it 'filters by email (partial match)' do
      get '/api/v1/users', params: { email: 'example.com' }
      json = JSON.parse(response.body)
      expect(json.size).to eq(3)
    end

    it 'filters by multiple parameters' do
      get '/api/v1/users', params: { first_name: 'John', last_name: 'Doe' }
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json.first['id']).to eq(user1.id)
    end

    it 'returns an empty array when no users match the filter' do
      get '/api/v1/users', params: { first_name: 'Kevin' }
      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json).to be_empty
    end
  end

  context 'with edge cases and negative filter scenarios' do
    it 'is case-insensitive when filtering by first_name' do
      get '/api/v1/users', params: { first_name: 'john' }
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      expect(json.map { |u| u['first_name'] }).to contain_exactly('John', 'Johnny')
    end

    it 'is case-insensitive when filtering by email' do
      get '/api/v1/users', params: { email: 'JANE.SMITH@EXAMPLE.COM' }
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json.first['id']).to eq(user2.id)
    end

    it 'returns an empty array for conflicting filters' do
      get '/api/v1/users', params: { first_name: 'John', last_name: 'Smith' }
      json = JSON.parse(response.body)
      expect(json).to be_empty
    end

    it 'does not return sensitive data in the user list' do
      get '/api/v1/users'
      json = JSON.parse(response.body)
      expect(json.first).not_to have_key('password')
      expect(json.first).not_to have_key('encrypted_password')
    end

    it 'correctly filters by a more specific first name' do
      get '/api/v1/users', params: { first_name: 'Jane' }
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json.first['id']).to eq(user2.id)
    end

    it 'filters by a partial string in the middle of an email' do
      get '/api/v1/users', params: { email: 'doe@exam' }
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json.first['id']).to eq(user1.id)
    end
  end

  it 'returns the response in JSON format' do
    get '/api/v1/users'
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end
end
