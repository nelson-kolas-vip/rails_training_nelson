class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  skip_before_action :verify_authenticity_token

  private

  def authenticate_admin!
    header = request.headers["Authorization"]
    token = Token.find_by(value: header)

    return unless token.blank? || token.expired_at < Time.current

    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
