class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_restaurant, only: [:index, :new, :create]
  before_action :set_reservation, only: [:create] # Assuming a reservation object is needed

  def create
    # Find the current user's active order, or create a new one
    @order = Order.find_or_initialize_by(user: current_user, restaurant: @restaurant, table: @reservation.table, status: :pending)

    # Process each item from the form
    order_params[:items].each do |item_param|
      menu_id = item_param[:menu_id].to_i
      quantity = item_param[:quantity].to_i

      # Find the menu item to get its details
      menu_item = Menu.find(menu_id)

      # Check if the item already exists in the order to update quantity
      existing_item = @order.items.find { |item| item["menu_id"] == menu_id }
      if existing_item
        existing_item["quantity"] = quantity
        existing_item["total_item_price"] = menu_item.price * quantity
      else
        @order.items << {
          "menu_id" => menu_id,
          "item_name" => menu_item.item_name,
          "quantity" => quantity,
          "unit_price" => menu_item.price,
          "total_item_price" => menu_item.price * quantity
        }
      end
    end

    # Update total price of the order
    @order.total_price = @order.items.sum { |item| item["total_item_price"].to_f }

    if @order.save
      redirect_to restaurant_orders_path(@restaurant), notice: "Order placed successfully!"
    else
      redirect_to restaurant_menus_path(@restaurant), alert: "Failed to place order."
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def set_reservation
    # You will need to find the current reservation.
    # This might be passed as a hidden field or stored in the session.
    # Assuming `reservation_id` is passed in the params for now.
    @reservation = Reservation.find(params[:order][:reservation_id])
  end

  def order_params
    params.require(:order).permit(
      :customer_name,
      :total_price,
      :reservation_id,
      items: [:menu_id, :quantity, :total_item_price]
    )
  end
end
