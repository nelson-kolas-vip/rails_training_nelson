class MenusController < ApplicationController
  before_action :set_restaurant
  before_action :set_menu, only: %i[edit update destroy]

  def index
    # Paginate the menus with a default of 12 items per page.
    @menus = @restaurant.menus.paginate(page: params[:page], per_page: 12)
    @reservation = Reservation.find_by(id: params[:reservation_id]) if params[:reservation_id].present?
  end

  def new
    @menu = @restaurant.menus.new
  end

  def create
    @menu = @restaurant.menus.new(menu_params)
    if @menu.save
      redirect_to restaurant_menus_path(@restaurant), notice: 'Menu item created.'
    else
      @menus = @restaurant.menus.reload
      render :index, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @menu.update(menu_params)
      redirect_to restaurant_menus_path(@restaurant), notice: "#{@menu.item_name.to_s.capitalize} item updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @menu.destroy
    redirect_to restaurant_menus_path(@restaurant), notice: 'Menu item deleted.'
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def set_menu
    @menu = @restaurant.menus.find(params[:id])
  end

  def menu_params
    params.require(:menu).permit(:item_name, :description, :price, :category, :available, :veg_status)
  end
end
