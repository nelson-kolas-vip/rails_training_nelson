require 'rails_helper'
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

  let(:headers) do
    { "CONTENT_TYPE" => "application/json" }
  end

  describe 'with valid params' do
    it 'creates a new user and returns a 201 status' do
      expect do
        post '/api/v1/users', params: valid_attributes.to_json, headers: headers
      end.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json['email']).to eq(valid_attributes[:email])
      expect(json['first_name']).to eq(valid_attributes[:first_name])
    end
  end

  describe 'with invalid params' do
    def post_with_invalid_attributes(attributes)
      expect do
        post '/api/v1/users', params: attributes.to_json, headers: headers
      end.not_to change(User, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    context 'when first_name is missing' do
      it 'does not create a user and returns an error' do
        invalid_attributes = valid_attributes.except(:first_name)
        post_with_invalid_attributes(invalid_attributes)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("First name is required")
      end
    end

    context 'when last_name is missing' do
      it 'does not create a user and returns an error' do
        invalid_attributes = valid_attributes.except(:last_name)
        post_with_invalid_attributes(invalid_attributes)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Last name is required")
      end
    end

    context 'when email is blank' do
      it 'does not create a user and returns an error' do
        invalid_attributes = valid_attributes.merge(email: '')
        post_with_invalid_attributes(invalid_attributes)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Email can't be blank")
      end
    end

    context 'when email is already taken' do
      before { User.create!(valid_attributes) }

      it 'returns a duplicate email error' do
        expect do
          post '/api/v1/users', params: valid_attributes.to_json, headers: headers
        end.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Email has already been taken')
      end
    end

    context 'when password is missing' do
      it 'does not create a user and returns an error' do
        invalid_attributes = valid_attributes.except(:password)
        post_with_invalid_attributes(invalid_attributes)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Password is required")
      end
    end

    context 'when password confirmation does not match' do
      it 'does not create a user and returns an error' do
        invalid_attributes = valid_attributes.merge(password_confirmation: 'wrongpassword')
        post_with_invalid_attributes(invalid_attributes)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Password confirmation doesn't match Password")
      end
    end

    context 'when phone_number is missing' do
      it 'does not create a user and returns an error' do
        invalid_attributes = valid_attributes.except(:phone_number)
        post_with_invalid_attributes(invalid_attributes)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Phone number is required")
      end
    end
  end
end
