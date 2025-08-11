module Api
  module V1
    class UsersController < ApplicationController
      def_param_group :user do
        property :id, Integer, desc: 'User ID'
        property :first_name, String, desc: 'First name of the user'
        property :last_name, String, desc: 'Last name of the user'
        property :email, String, desc: 'User email'
        property :created_at, String, desc: 'Account creation date'
      end

      api :GET, '/api/v1/users', 'Get all available users'
      returns array_of: :user, code: 200, desc: 'List of all users'
      def index
        users = User.all
        render json: users, each_serializer: UserSerializer
      end

      def_param_group :user_input do
        param :first_name, String, required: true
        param :last_name, String, required: true
        param :email, String, required: true, allow_nil: true
        param :phone_number, String, required: true
        param :password, String, required: true
        param :password_confirmation, String, required: true
        param :age, Integer, required: true
        param :date_of_birth, String, required: true, desc: 'Format: YYYY-MM-DD'
      end

      api :POST, '/api/v1/users', 'Create a new User'
      param_group :user_input
      returns code: 201, desc: 'User created' do
        param_group :user
      end
      def create
        outcome = Api::V1::CreateUserInteraction.run(user_params)

        if outcome.valid?
          render json: outcome.result, serializer: UserSerializer, status: :created
        else
          render json: { errors: outcome.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(
          :first_name,
          :last_name,
          :email,
          :phone_number,
          :password,
          :password_confirmation,
          :age,
          :date_of_birth
        )
      end
    end
  end
end
