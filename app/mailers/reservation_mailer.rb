class ReservationMailer < ApplicationMailer
  default from: 'reservations@railsresto.com'
  def reservation_request_received_email(reservation)
    @reservation = reservation
    @restaurant = reservation.restaurant
    mail(to: @reservation.user.email, subject: 'Your Reservation Request Has Been Received')
  end

  def reservation_confirmed_email(reservation)
    @reservation = reservation
    @restaurant = reservation.restaurant
    mail(to: @reservation.user.email, subject: 'Your Reservation at ' + @restaurant.name + ' Is Confirmed!')
  end

  def rejection_email(reservation)
    @reservation = reservation
    @restaurant = reservation.restaurant
    mail(to: @reservation.user.email, subject: 'Your Reservation at ' + @restaurant.name + ' Has Been Rejected')
  end
end
