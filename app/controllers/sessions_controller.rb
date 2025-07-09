class SessionsController < ApplicationController
  # This just renders the login form
  def new
  end

  # This handles the login logic
  def create
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      puts "User Logged In: #{user.email}"
      puts user.authenticate(params[:password]) if user
      redirect_to homepage_path, notice: "Logged in successfully!"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new
    end
  end

  # This handles the logout logic
  def destroy
    session.delete(:user_id)
    redirect_to login_path, notice: "Logged out successfully!"
  end
end
