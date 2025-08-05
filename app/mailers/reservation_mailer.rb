# app/mailers/reservation_mailer.rb
class ReservationMailer < ApplicationMailer
  default from: 'reservations@railsresto.com'

  # Email sent to customer when a new reservation request is received (status: pending)
  def reservation_request_received_email(reservation)
    @reservation = reservation
    @restaurant = reservation.restaurant
    mail(to: @reservation.user.email, subject: 'Your Reservation Request Has Been Received')
  end

  # Email sent to customer when their reservation is confirmed by staff
  def reservation_confirmed_email(reservation)
    @reservation = reservation
    @restaurant = reservation.restaurant
    mail(to: @reservation.user.email, subject: 'Your Reservation at ' + @restaurant.name + ' Is Confirmed!')
  end

  # Email sent to customer when their reservation is rejected by staff
  def rejection_email(reservation)
    @reservation = reservation
    @restaurant = reservation.restaurant
    mail(to: @reservation.user.email, subject: 'Your Reservation at ' + @restaurant.name + ' Has Been Rejected')
  end
end
