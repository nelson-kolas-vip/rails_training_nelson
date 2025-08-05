# app/controllers/reservations_controller.rb
class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_restaurant, only: [:new, :create, :index]
  before_action :set_reservation, only: [:accept, :reject, :edit, :update]
  before_action :authorize_staff!, only: [:accept, :reject, :edit, :update]

  def index
    @reservations = if current_user.staff?
                      # Staff users see all reservations for their restaurant, ordered
                      @restaurant.reservations.order(reservation_date: :asc, reservation_time: :asc)
                    else
                      # Customers only see their own reservations for the specific restaurant, ordered
                      current_user.reservations.where(restaurant: @restaurant).order(reservation_date: :asc, reservation_time: :asc)
                    end
  end

  def new
    @reservation = @restaurant.reservations.new(
      customer_name: "#{current_user.first_name} #{current_user.last_name}",
      customer_contact: current_user.email
    )

    # Fetch all tables for the dropdown, regardless of initial status
    @tables = @restaurant.tables

    # Pre-select table if table_id is passed in params (e.g., from a "Reserve" button on a table)
    return unless params[:table_id].present?

    @preselected_table = @restaurant.tables.find_by(id: params[:table_id])
    @reservation.table_id = @preselected_table.id if @preselected_table
  end

  def create
    @reservation = @restaurant.reservations.new(reservation_params)
    @reservation.user = current_user
    @reservation.status = :pending # Explicitly set reservation status to pending upon creation

    # Find the selected table to validate seating capacity and update its status
    @table = Table.find_by(id: @reservation.table_id)

    # Basic validation for number of guests
    if @reservation.number_of_guests.to_i < 1
      flash.now[:alert] = "The number of guests must be at least 1."
      @tables = @restaurant.tables # Re-fetch tables for the form
      render :new, status: :unprocessable_entity
      return
    end

    # Validate number of guests against table seating capacity
    if @table && @reservation.number_of_guests > @table.seating_capacity
      flash.now[:alert] = "The number of guests exceeds the seating capacity of the selected table (max #{@table.seating_capacity})."
      @tables = @restaurant.tables # Re-fetch tables for the form
      render :new, status: :unprocessable_entity
      return
    end

    if @reservation.save
      # When customer reserves, reservation status is 'pending' and table status becomes 'under_reservation'
      @reservation.table.update(status: :under_reservation)
      # Trigger confirmation email on successful creation
      ReservationMailer.reservation_request_received_email(@reservation).deliver_later
      redirect_to restaurant_tables_path(@restaurant), notice: 'Reservation created successfully and is pending confirmation.'
    else
      flash.now[:alert] = "Failed to create reservation: #{@reservation.errors.full_messages.to_sentence}"
      @tables = @restaurant.tables # Re-fetch tables for the form
      render :new, status: :unprocessable_entity
    end
  end

  # Staff action to edit a reservation
  def edit
    @restaurant = @reservation.restaurant # Ensure @restaurant is set for the form
    @tables = @restaurant.tables # Fetch all tables for the dropdown
  end

  # Staff action to update a reservation
  def update
    @table = Table.find_by(id: reservation_params[:table_id])

    # Guest count validation
    if reservation_params[:number_of_guests].to_i < 1
      flash.now[:alert] = "The number of guests must be at least 1."
      @restaurant = @reservation.restaurant
      @tables = @restaurant.tables
      render :edit, status: :unprocessable_entity
      return
    end

    if @table && reservation_params[:number_of_guests].to_i > @table.seating_capacity
      flash.now[:alert] = "The number of guests exceeds the seating capacity of the selected table (max #{@table.seating_capacity})."
      @restaurant = @reservation.restaurant
      @tables = @restaurant.tables
      render :edit, status: :unprocessable_entity
      return
    end

    # Handle table status change if table_id is updated
    if @reservation.table_id != reservation_params[:table_id].to_i
      old_table = @reservation.table
      if @reservation.update(reservation_params)
        # Revert old table status based on its previous state or a default
        old_table.update(status: :available) if old_table.present? && old_table.id != @table.id

        # Set new table status based on the reservation's current status
        if @reservation.confirmed?
          @table.update(status: :reserved)
        elsif @reservation.pending?
          @table.update(status: :under_reservation)
        end
        redirect_to restaurant_reservations_path(@reservation.restaurant), notice: 'Reservation updated successfully.'
      else
        flash.now[:alert] = "Failed to update reservation: #{@reservation.errors.full_messages.to_sentence}"
        @restaurant = @reservation.restaurant
        @tables = @restaurant.tables
        render :edit, status: :unprocessable_entity
      end
    elsif @reservation.update(reservation_params) # Table ID not changed, just update reservation attributes
      redirect_to restaurant_reservations_path(@reservation.restaurant), notice: 'Reservation updated successfully.'
    else
      flash.now[:alert] = "Failed to update reservation: #{@reservation.errors.full_messages.to_sentence}"
      @restaurant = @reservation.restaurant
      @tables = @restaurant.tables
      render :edit, status: :unprocessable_entity
    end
  end

  # Staff action to confirm a reservation
  def accept
    if @reservation.pending?
      @reservation.confirmed! # Change reservation status to confirmed
      # When staff accepts, reservation status is 'confirmed' and table status becomes 'reserved'
      @reservation.table.update(status: :reserved)
      # Trigger confirmation email on acceptance
      ReservationMailer.reservation_confirmed_email(@reservation).deliver_later
      redirect_to restaurant_reservations_path(@reservation.restaurant), notice: 'Reservation confirmed.'
    else
      redirect_to restaurant_reservations_path(@reservation.restaurant), alert: 'Reservation cannot be confirmed as it is not pending.'
    end
  end

  # Staff action to reject a reservation
  def reject
    if @reservation.pending? || @reservation.confirmed? # Allow rejection of pending or confirmed
      @reservation.rejected! # Change reservation status to rejected
      # When staff rejects, reservation status is 'rejected' and table status reverts to 'available'
      @reservation.table.update(status: :available)
      # Trigger rejection email on rejection
      ReservationMailer.rejection_email(@reservation).deliver_later
      redirect_to restaurant_reservations_path(@reservation.restaurant), notice: 'Reservation rejected and table made available.'
    else
      redirect_to restaurant_reservations_path(@reservation.restaurant), alert: 'Reservation cannot be rejected from its current state.'
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:reservation_date, :reservation_time, :number_of_guests, :customer_name, :customer_contact, :table_id, :status)
  end

  def authorize_staff!
    return if current_user.staff?

    redirect_to root_path, alert: "Access denied. Only staff can perform this action."
  end
end
