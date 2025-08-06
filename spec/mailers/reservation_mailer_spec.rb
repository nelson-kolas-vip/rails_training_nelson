require "rails_helper"

RSpec.describe ReservationMailer, type: :mailer do
  let!(:staff_user) { FactoryBot.create(:staff_user) }
  let!(:customer_user) { FactoryBot.create(:customer_user) }
  let!(:restaurant) { FactoryBot.create(:restaurant, user: staff_user) }
  let!(:table) { FactoryBot.create(:table, restaurant: restaurant, status: :available, seating_capacity: 4) }

  let!(:pending_reservation) { FactoryBot.create(:reservation, restaurant: restaurant, user: customer_user, table: table, status: :pending) }

  describe "#reservation_request_received_email" do
    let(:mail) { ReservationMailer.reservation_request_received_email(pending_reservation) }

    it "renders the headers" do
      expect(mail.subject).to eq("Your Reservation Request Has Been Received")
      expect(mail.to).to eq([customer_user.email])
      expect(mail.from).to eq(["reservations@railsresto.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("Thank you for your reservation request")
    end

    context "when recipient email is missing" do
      let!(:reservation_without_email) { FactoryBot.build(:reservation, restaurant: restaurant, user: FactoryBot.build(:customer_user, email: nil), table: table, status: :pending) }
      let(:mail_no_email) { ReservationMailer.reservation_request_received_email(reservation_without_email) }
    end
  end

  describe "#reservation_confirmed_email" do
    let!(:confirmed_reservation) { FactoryBot.create(:reservation, restaurant: restaurant, user: customer_user, table: table, status: :confirmed) }
    let(:mail) { ReservationMailer.reservation_confirmed_email(confirmed_reservation) }

    it "renders the headers" do
      expect(mail.subject).to eq("Your Reservation at #{restaurant.name} Is Confirmed!")
      expect(mail.to).to eq([customer_user.email])
      expect(mail.from).to eq(["reservations@railsresto.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("Reservation Confirmed")
    end

    context "when recipient email is missing" do
      let!(:reservation_without_email) { FactoryBot.build(:reservation, restaurant: restaurant, user: FactoryBot.build(:customer_user, email: nil), table: table, status: :confirmed) }
      let(:mail_no_email) { ReservationMailer.reservation_confirmed_email(reservation_without_email) }
    end
  end

  describe "#rejection_email" do
    let!(:rejected_reservation) { FactoryBot.create(:reservation, restaurant: restaurant, user: customer_user, table: table, status: :rejected) }
    let(:mail) { ReservationMailer.rejection_email(rejected_reservation) }

    it "renders the headers" do
      expect(mail.subject).to eq("Your Reservation at #{restaurant.name} Has Been Rejected")
      expect(mail.to).to eq([customer_user.email])
      expect(mail.from).to eq(["reservations@railsresto.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("We regret to inform you that your")
    end
  end
end
