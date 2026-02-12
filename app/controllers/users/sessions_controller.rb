module Users
  class SessionsController < Devise::SessionsController
    before_action :validate_role_param, only: [:new, :create]
    before_action :check_user_role_match, only: [:create]

    def new
      # `validate_role_param` will handle invalid/missing role
      super
    end

    private

    def validate_role_param
      valid_roles = %w[admin staff customer]
      return if params[:role].present? && valid_roles.include?(params[:role])

      redirect_to root_path, alert: 'Role is required to sign in.' and return
    end

    def check_user_role_match
      return unless params[:user].present?

      user = User.find_by(email: params[:user][:email].downcase)
      return if user.blank?

      # Check password validity
      return unless user.valid_password?(params[:user][:password])

      expected_role = params[:role]
      actual_role_str = User.role_type_to_string(user.role_type_before_type_cast)

      return unless actual_role_str != expected_role

      flash[:alert] = "You are not authorized to log in from this portal. Kindly login from #{actual_role_str} portal."
      redirect_to new_user_session_path(role: expected_role) and return
    end
  end
end
