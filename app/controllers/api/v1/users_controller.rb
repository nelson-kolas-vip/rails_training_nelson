module Api
  module V1
    class UsersController < ApplicationController
      # skip_before_action :verify_authenticity_token
      before_action :authenticate_admin!
      def_param_group :user_base do
        property :id, Integer, desc: 'User ID'
        property :first_name, String, desc: 'First name'
        property :last_name, String, desc: 'Last name'
        property :email, String, desc: 'Email'
        property :phone_number, String, desc: 'Phone number'
        property :age, Integer, desc: 'Age'
        property :date_of_birth, String, desc: 'Date of birth'
        property :created_at, String, desc: 'Created at'
      end

      def_param_group :user_input do
        param :first_name, String, desc: 'First name of the user', required: false
        param :last_name, String, desc: 'Last name of the user', required: false
        param :email, String, desc: 'Email address of the user', required: false
        param :phone_number, String, desc: 'Phone number of the user', required: false
        param :password, String, desc: 'Password for the user', required: false
        param :password_confirmation, String, desc: 'Password confirmation', required: false
        param :age, Integer, desc: 'Age of the user', required: false
        param :date_of_birth, String, desc: 'Date of birth (YYYY-MM-DD)', required: false
      end

      api :GET, '/api/v1/users', 'Returns a list of users with optional filters'
      param :first_name, String, desc: 'Filter by first name (partial match)', required: false
      param :last_name, String, desc: 'Filter by last name (partial match)', required: false
      param :email, String, desc: 'Filter by email (partial match)', required: false
      returns array_of: :user_base, code: 200, desc: 'A list of users'
      def index
        users = Api::V1::UsersQuery.new(params).call
        render json: users, each_serializer: UserSerializer
      end

      api :POST, '/api/v1/users', 'Create a new user'
      param_group :user_input
      returns code: 201, desc: 'User created successfully' do
        param_group :user_base
      end
      error code: 422, desc: 'Validation failed'
      def create
        outcome = Api::V1::CreateUserInteraction.run(user_params)
        if outcome.valid?
          render json: outcome.result, serializer: UserSerializer, status: :created
        else
          render json: { errors: outcome.errors.full_messages }, status: :unprocessable_entity
        end
      end

      api :GET, '/api/v1/users/:id', 'Show user by ID'
      param :id, :number, required: true, desc: 'User ID'
      returns code: 200, desc: 'User details' do
        param_group :user_base
      end
      error code: 404, desc: 'User not found'
      def show
        return render json: { error: 'ID is blank' }, status: :not_found if params[:id].blank?

        user = User.find_by(id: params[:id].to_i)
        if user
          render json: user, serializer: UserSerializer
        else
          render json: { error: 'User not found' }, status: :not_found
        end
      end

      api :PUT, '/api/v1/users/:id', 'Update an existing user'
      param :id, :number, required: true, desc: 'User ID'
      param_group :user_input
      returns code: 200, desc: 'User updated successfully' do
        param_group :user_base
      end
      error code: 404, desc: 'User not found'
      error code: 422, desc: 'Validation errors'
      def update
        user_id = params[:id].to_i
        outcome = Api::V1::UpdateUserInteraction.run(user_update_params.merge(id: user_id))
        if outcome.valid?
          render json: outcome.result, serializer: UserSerializer
        else
          status = outcome.errors.full_messages.include?("User not found") ? :not_found : :unprocessable_entity
          render json: { errors: outcome.errors.full_messages }, status: status
        end
      end

      api :DELETE, '/api/v1/users/:id', 'Delete a user'
      param :id, :number, required: true, desc: 'User ID to delete'
      returns code: 200, desc: 'User successfully deleted'
      error code: 404, desc: 'User not found'
      def destroy
        outcome = Api::V1::DestroyUserInteraction.run(id: params[:id].to_i)
        if outcome.valid?
          render json: { message: 'User deleted successfully' }, status: :ok
        else
          render json: { errors: outcome.errors.full_messages }, status: :not_found
        end
      end

      private

      def user_params
        params.permit(:first_name, :last_name, :email, :phone_number, :password, :password_confirmation, :age, :date_of_birth)
      end

      def user_update_params
        params.permit(:first_name, :last_name, :email, :phone_number, :password, :password_confirmation, :age, :date_of_birth)
      end
    end
  end
end
