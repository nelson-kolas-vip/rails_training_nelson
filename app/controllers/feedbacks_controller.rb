class FeedbacksController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create] # Only logged-in users can leave feedback
  before_action :set_restaurant, only: [:new, :create] # Associate feedback with a specific restaurant

  def index
    if params[:restaurant_id].present?
      @restaurant = Restaurant.find(params[:restaurant_id])
      @feedbacks = @restaurant.feedbacks.order(created_at: :desc)
    else
      @restaurant = nil
      @feedbacks = Feedback.all.order(created_at: :desc)
    end
  end

  def new
    @feedback = if @restaurant
                  @restaurant.feedbacks.new(
                    customer_name: "#{current_user.first_name} #{current_user.last_name}",
                    user: current_user
                  )
                else
                  Feedback.new(
                    customer_name: "#{current_user.first_name} #{current_user.last_name}",
                    user: current_user
                  )
                end
  end

  def create
    @feedback = if @restaurant
                  @restaurant.feedbacks.new(feedback_params)
                else
                  Feedback.new(feedback_params)
                end

    @feedback.user = current_user
    prev_url = params[:previous_url]
    @feedback.current_user_url = prev_url
    if @feedback.save
      if @restaurant
        redirect_to params[:previous_url] || root_path, notice: 'Feedback submitted successfully!'
      else
        redirect_to root_path, notice: 'Feedback submitted successfully!'
      end
    else
      flash.now[:alert] = "Failed to submit feedback: #{@feedback.errors.full_messages.to_sentence}"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_restaurant
    # Dynamically check if restaurant_id is present in params
    @restaurant = if params[:restaurant_id].present?
                    Restaurant.find(params[:restaurant_id])
                  else
                    # If no restaurant_id, set @restaurant to nil, as feedback can be general
                    nil
                  end
  end

  def feedback_params
    params.require(:feedback).permit(:rating, :comment, :customer_name, :current_user_url)
  end
end
