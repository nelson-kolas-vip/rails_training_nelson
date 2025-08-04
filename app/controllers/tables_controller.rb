class TablesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_restaurant

  def index
    @restaurant = Restaurant.find(params[:restaurant_id])
    @status_filter = params[:status]
    @search = params[:search]
    @sort_column = params[:sort] || 'table_number'

    @tables = @restaurant.tables

    @tables = @tables.where(status: @status_filter) if @status_filter.present? && Table.statuses.key?(@status_filter)

    if @search.present?
      query = "%#{@search.strip.downcase}%"
      @tables = @tables.where(
        "CAST(table_number AS TEXT) ILIKE :q OR CAST(seating_capacity AS TEXT) ILIKE :q OR CAST(status AS TEXT) ILIKE :q",
        q: query
      )
    end

    @tables = @tables.order(@sort_column).paginate(page: params[:page], per_page: 5)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @table = @restaurant.tables.new(table_params)
    if @table.save
      redirect_to restaurant_tables_path(@restaurant), notice: "Table created successfully."
    else
      redirect_to restaurant_tables_path(@restaurant), alert: "Failed to create table."
    end
  end

  def update
    @table = @restaurant.tables.find(params[:id])
    if @table.update(table_params)
      redirect_to restaurant_tables_path(@restaurant), notice: "Table updated successfully."
    else
      redirect_to restaurant_tables_path(@restaurant), alert: "Failed to update table."
    end
  end

  def destroy
    @table = @restaurant.tables.find(params[:id])
    if @table.destroy
      redirect_to restaurant_tables_path(@restaurant), notice: "Table deleted successfully."
    else
      redirect_to restaurant_tables_path(@restaurant), alert: "Failed to delete table."
    end
  end

  private

  def table_params
    params.require(:table).permit(:table_number, :seating_capacity, :status)
  end

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end
end
