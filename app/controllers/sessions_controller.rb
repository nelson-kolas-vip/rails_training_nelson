class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = "Signed in successfully!"
      puts "User Logging: #{user.email}" # Debugging line to check user ID
      redirect_to homepage_path
    else
      flash.now[:alert] = "Invalid email or password."
      render :new
    end
  end

  def destroy
    session.delete(:user_id)
    flash[:notice] = "Signed out successfully!"
    redirect_to root_path
  end
end
