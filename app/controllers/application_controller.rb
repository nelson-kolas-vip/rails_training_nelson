class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  private

  def authenticate_admin!
    header = request.headers["Authorization"]
    token = Token.find_by(value: header)

    return unless token.blank? || token.expired_at < Time.current

    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  protected

  def after_sign_in_path_for(resource)
    homepage_path
  end

  def after_sign_up_path_for(resource)
    homepage_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
