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
      returns array_of: :user, code: 200, desc: 'List of All Users'
      def index
        users = User.all
        render json: users, each_serializer: UserSerializer
      end
    end
  end
end
