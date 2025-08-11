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

  # Create a token to be used for authorization
  let!(:token) { create(:token) }
  let(:auth_headers) do
    {
      "CONTENT_TYPE" => "application/json",
      "Authorization" => token.value
    }
  end

  describe 'with valid params' do
    before { post '/api/v1/users', params: valid_attributes.to_json, headers: auth_headers }

    it 'creates a new user' do
      expect do
        post '/api/v1/users', params: valid_attributes.merge(email: Faker::Internet.unique.email).to_json, headers: auth_headers
      end.to change(User, :count).by(1)
    end

    it 'returns a 201 created status' do
      expect(response).to have_http_status(:created)
    end

    it 'returns the created user details' do
      json = JSON.parse(response.body)
      expect(json['email']).to eq(valid_attributes[:email])
      expect(json['first_name']).to eq(valid_attributes[:first_name])
    end

    it 'returns the response in JSON format' do
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end
  end

  describe 'with invalid params' do
    def post_with_invalid_attributes(attributes)
      expect do
        post '/api/v1/users', params: attributes.to_json, headers: auth_headers
      end.not_to change(User, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    context 'when a required field is missing' do
      it 'fails if first_name is missing' do
        post_with_invalid_attributes(valid_attributes.except(:first_name))
        expect(JSON.parse(response.body)['errors']).to include("First name is required")
      end

      it 'fails if last_name is missing' do
        post_with_invalid_attributes(valid_attributes.except(:last_name))
        expect(JSON.parse(response.body)['errors']).to include("Last name is required")
      end

      it 'fails if phone_number is missing' do
        post_with_invalid_attributes(valid_attributes.except(:phone_number))
        expect(JSON.parse(response.body)['errors']).to include("Phone number is required")
      end
    end

    context 'with invalid email' do
      it 'fails for a blank email' do
        post_with_invalid_attributes(valid_attributes.merge(email: ''))
        expect(JSON.parse(response.body)['errors']).to include("Email can't be blank")
      end

      it 'fails for an invalid email format' do
        post_with_invalid_attributes(valid_attributes.merge(email: 'not-an-email'))
        expect(JSON.parse(response.body)['errors']).to include('Email is invalid')
      end

      it 'fails when email is already taken' do
        User.create!(valid_attributes)
        post_with_invalid_attributes(valid_attributes)
        expect(JSON.parse(response.body)['errors']).to include('Email has already been taken')
      end
    end

    context 'with invalid password' do
      it 'fails if password is missing' do
        post_with_invalid_attributes(valid_attributes.except(:password))
        expect(JSON.parse(response.body)['errors']).to include("Password is required")
      end

      it "fails if password confirmation doesn't match" do
        post_with_invalid_attributes(valid_attributes.merge(password_confirmation: 'wrongpassword'))
        expect(JSON.parse(response.body)['errors']).to include("Password confirmation doesn't match Password")
      end
    end

    context 'with invalid data formats' do
      it 'fails for invalid date_of_birth format' do
        post_with_invalid_attributes(valid_attributes.merge(date_of_birth: 'not-a-valid-date'))
        expect(JSON.parse(response.body)['errors']).to include('Date of birth is not a valid date')
      end

      it 'fails for a non-integer age' do
        post_with_invalid_attributes(valid_attributes.merge(age: 'thirty'))
        expect(JSON.parse(response.body)['errors']).to include('Age is not a valid integer')
      end
    end
  end
end
