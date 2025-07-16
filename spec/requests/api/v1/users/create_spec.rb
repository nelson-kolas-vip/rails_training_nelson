require 'rails_helper'
# This will Disable apipie param validation in tests
Apipie.configuration.validate = false if defined?(Apipie)

RSpec.describe 'POST /api/v1/users', type: :request do
  let(:valid_attributes) do
    {
      first_name: 'Dummy',
      last_name: 'Doe',
      email: Faker::Internet.unique.email,
      phone_number: '1234567890',
      password: 'rails@123',
      password_confirmation: 'rails@123',
      age: 30,
      date_of_birth: '1995-01-01'
    }
  end

  let(:invalid_attributes) do
    valid_attributes.merge(email: '') # invalid because email is blank
  end

  let(:headers) do
    { "CONTENT_TYPE" => "application/json" }
  end

  describe 'with valid params' do
    it 'creates a new user' do
      expect do
        post '/api/v1/users', params: valid_attributes.to_json, headers: headers
      end.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['email']).to eq(valid_attributes[:email])
    end
  end

  describe 'with invalid params' do
    it 'does not create a new user' do
      expect do
        post '/api/v1/users', params: invalid_attributes.to_json, headers: headers
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to include("Email can't be blank")
    end
  end

  describe 'when email is already taken' do
    before { User.create!(valid_attributes) }

    it 'returns an error' do
      post '/api/v1/users', params: valid_attributes.to_json, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to include('Email has already been taken')
    end
  end
end
