class RestaurantsController < ApplicationController
  before_action :authenticate_user!

  def index
    @restaurants = case params[:sort]
                   when 'rating'
                     Restaurant.left_joins(:feedbacks)
                               .group('restaurants.id')
                               .order(Arel.sql("coalesce(avg(feedbacks.rating), 0) DESC"))
                               .paginate(page: params[:page], per_page: 10)
                   when 'name'

                     Restaurant.order(name: :asc).paginate(page: params[:page], per_page: 10)
                   else

                     Restaurant.all.order(created_at: :desc).paginate(page: params[:page], per_page: 10)
                   end
  end

  def new
    @restaurant = Restaurant.new
  end

  def create
    @restaurant = current_user.restaurants.build(restaurant_params)

    if @restaurant.save
      redirect_to root_path, notice: "Your Restaurant was created and is open for business."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def restaurant_params
    params.require(:restaurant).permit(:name, :description, :location, :cuisine_type)
  end
end
