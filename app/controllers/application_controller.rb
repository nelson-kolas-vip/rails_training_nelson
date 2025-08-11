class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

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
