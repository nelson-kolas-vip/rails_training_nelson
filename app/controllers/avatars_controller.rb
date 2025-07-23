class AvatarsController < ApplicationController
  # before_action :authenticate_user!

  def edit
  end

  def update
    if current_user.update(avatar_params)
      redirect_to edit_avatar_path, notice: "Avatar updated successfully."
    else
      flash.now[:alert] = current_user.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.avatar.purge
    redirect_to edit_avatar_path, notice: "Avatar deleted."
  end

  private

  def avatar_params
    params.require(:user).permit(:avatar)
  end
end
