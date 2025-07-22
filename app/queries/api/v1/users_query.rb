module Api
  module V1
    class UsersQuery
      def initialize(params = {})
        @params = params
      end

      def call
        users = User.all
        users = users.where("first_name ILIKE ?", "%#{@params[:first_name]}%") if @params[:first_name].present?
        users = users.where("last_name ILIKE ?", "%#{@params[:last_name]}%") if @params[:last_name].present?
        users = users.where("email ILIKE ?", "%#{@params[:email]}%") if @params[:email].present?
        users
      end
    end
  end
end
