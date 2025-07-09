class UsersController < ApplicationController
  def new
    @user = User.new
    if @user.save
      flash[:notice] = "Account created successfully."
      redirect_to homepage_path
    else
      render :new
    end
  end

  private def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :age, :date_of_birth)
  end
end
