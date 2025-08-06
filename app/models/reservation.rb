class Reservation < ApplicationRecord
  belongs_to :restaurant
  belongs_to :table
  belongs_to :user
  enum :status, { pending: 0, confirmed: 1, rejected: 2 }

  validates :reservation_date, :reservation_time, :number_of_guests, :customer_name, :customer_contact, presence: true
  validates :number_of_guests, numericality: { only_integer: true, greater_than: 0 }

  def no_double_booking
    existing_active_reservations = Reservation.where(
      table_id: table_id,
      reservation_date: reservation_date,
      reservation_time: reservation_time
    ).where.not(id: id).where(status: [:pending, :confirmed])

    return unless existing_active_reservations.exists?

    errors.add(:base, "This table is already booked for the selected date and time.")
  end
end
