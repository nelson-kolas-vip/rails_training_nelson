require 'rails_helper'

RSpec.describe ReservationsController, type: :request do
  let!(:staff_user) { FactoryBot.create(:staff_user) }
  let!(:customer_user) { FactoryBot.create(:customer_user) }
  let!(:restaurant) { FactoryBot.create(:restaurant, user: staff_user) }
  let!(:table) { FactoryBot.create(:table, restaurant: restaurant, status: :available, seating_capacity: 4) }
  let!(:another_table) { FactoryBot.create(:table, restaurant: restaurant, status: :available, seating_capacity: 6) }

  include ActiveJob::TestHelper

  describe "GET #index" do
    context "when a staff user is signed in" do
      before do
        sign_in staff_user, scope: :user
        FactoryBot.create(:reservation, restaurant: restaurant, user: staff_user, table: table)
        FactoryBot.create(:reservation, restaurant: restaurant, user: customer_user, table: another_table)
      end

      it "renders a successful response and shows all reservations for their restaurant" do
        get restaurant_reservations_path(restaurant)
        expect(response).to be_successful
        expect(response.body).to include("#{restaurant.name}")
        expect(restaurant.reservations.count).to eq(2)
      end
    end

    context "when a customer user is signed in" do
      let!(:customer_reservation) { FactoryBot.create(:reservation, restaurant: restaurant, user: customer_user, table: table) }
      let!(:other_customer_reservation) { FactoryBot.create(:reservation, restaurant: restaurant, user: FactoryBot.create(:customer_user), table: another_table) }

      before { sign_in customer_user, scope: :user }

      it "renders a successful response and shows only their own reservations for the restaurant" do
        get restaurant_reservations_path(restaurant)
        expect(response).to be_successful
        expect(response.body).to include(customer_reservation.customer_name)
        expect(response.body).not_to include(other_customer_reservation.customer_name)
      end
    end

    context "when user is not signed in" do
      it "redirects to the sign in page" do
        get restaurant_reservations_path(restaurant)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET #new" do
    context "when a customer user is signed in" do
      before { sign_in customer_user, scope: :user }

      it "renders a successful response" do
        get new_restaurant_reservation_path(restaurant)
        expect(response).to be_successful
        expect(response.body).to include("Reserve a Table at #{restaurant.name}")
        expect(response.body).to include(customer_user.first_name)
      end

      it "pre-selects a table if table_id param is present" do
        get new_restaurant_reservation_path(restaurant, table_id: table.id)
        expect(response).to be_successful
        expect(response.body).to include("Selected Table: <strong>##{table.table_number}</strong>")
        expect(response.body).to include("disabled")
      end
    end

    context "when user is not signed in" do
      it "redirects to the sign in page" do
        get new_restaurant_reservation_path(restaurant)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST #create" do
    before { sign_in customer_user, scope: :user }
    let(:valid_params) do
      {
        reservation_date: Date.tomorrow,
        reservation_time: Time.zone.now.change(hour: 18, min: 0),
        number_of_guests: 2,
        customer_name: "Test Customer",
        customer_contact: "test@example.com",
        table_id: table.id
      }
    end

    context "with valid parameters" do
      it "creates a new reservation" do
        expect do
          post restaurant_reservations_path(restaurant), params: { reservation: valid_params }
        end.to change(Reservation, :count).by(1)
      end
    end

    context "when user is not signed in" do
      before { sign_out customer_user }
      it "does not create a reservation and redirects to sign in" do
        expect do
          post restaurant_reservations_path(restaurant), params: { reservation: valid_params }
        end.to_not change(Reservation, :count)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET #edit" do
    let!(:reservation_to_edit) { FactoryBot.create(:reservation, restaurant: restaurant, user: customer_user, table: table, status: :pending) }

    context "when a staff user is signed in" do
      before { sign_in staff_user, scope: :user }
    end
  end

  describe "PATCH #update" do
    let!(:reservation_to_update) { FactoryBot.create(:reservation, restaurant: restaurant, user: customer_user, table: table, status: :pending) }

    context "when a staff user is signed in" do
      before { sign_in staff_user, scope: :user }

      context "with valid parameters (no table change)" do
        let(:update_params) { { number_of_guests: 3, customer_name: "Updated Name" } }
      end

      context "with valid parameters (with table change)" do
        let(:update_params) { { table_id: another_table.id, number_of_guests: 5 } }
      end
    end
  end

  describe "PATCH #accept" do
    let!(:pending_reservation) { FactoryBot.create(:reservation, restaurant: restaurant, user: customer_user, table: table, status: :pending) }

    context "when a staff user is signed in" do
      before { sign_in staff_user, scope: :user }

      it "changes reservation status to confirmed and table status to reserved" do
        table.update(status: :under_reservation)
        pending_reservation.reload

        patch accept_restaurant_reservation_path(restaurant, pending_reservation)
        pending_reservation.reload
        table.reload
        expect(pending_reservation.confirmed?).to be true
        expect(table.reserved?).to be true
        expect(response).to redirect_to(restaurant_reservations_path(restaurant))
        follow_redirect!
        expect(response.body).to include("Reservation confirmed.")
      end

      it "does not confirm a non-pending reservation" do
        confirmed_reservation = FactoryBot.create(:reservation, restaurant: restaurant, user: customer_user, table: another_table, status: :confirmed)
        patch accept_restaurant_reservation_path(restaurant, confirmed_reservation)
        confirmed_reservation.reload
        expect(confirmed_reservation.confirmed?).to be true
        expect(response).to redirect_to(restaurant_reservations_path(restaurant))
        follow_redirect!
        expect(response.body).to include("Reservation cannot be confirmed as it is not pending.")
      end
    end
  end

  describe "PATCH #reject" do
    let!(:pending_reservation_to_reject) { FactoryBot.create(:reservation, restaurant: restaurant, user: customer_user, table: table, status: :pending) }
    let!(:confirmed_reservation_to_reject) { FactoryBot.create(:reservation, restaurant: restaurant, user: customer_user, table: another_table, status: :confirmed) }

    context "when a staff user is signed in" do
      before { sign_in staff_user, scope: :user }

      it "changes pending reservation status to rejected and table status to available" do
        table.update(status: :under_reservation)
        pending_reservation_to_reject.reload

        patch reject_restaurant_reservation_path(restaurant, pending_reservation_to_reject)
        pending_reservation_to_reject.reload
        table.reload
        expect(pending_reservation_to_reject.rejected?).to be true
        expect(table.available?).to be true
        expect(response).to redirect_to(restaurant_reservations_path(restaurant))
        follow_redirect!
        expect(response.body).to include("Reservation rejected and table made available.")
      end

      it "changes confirmed reservation status to rejected and table status to available" do
        another_table.update(status: :reserved)
        confirmed_reservation_to_reject.reload

        patch reject_restaurant_reservation_path(restaurant, confirmed_reservation_to_reject)
        confirmed_reservation_to_reject.reload
        another_table.reload
        expect(confirmed_reservation_to_reject.rejected?).to be true
        expect(another_table.available?).to be true
        expect(response).to redirect_to(restaurant_reservations_path(restaurant))
        follow_redirect!
        expect(response.body).to include("Reservation rejected and table made available.")
      end

      it "does not reject an already rejected reservation" do
        rejected_reservation = FactoryBot.create(:reservation, restaurant: restaurant, user: customer_user, table: table, status: :rejected)
        patch reject_restaurant_reservation_path(restaurant, rejected_reservation)
        rejected_reservation.reload
        expect(rejected_reservation.rejected?).to be true
        expect(response).to redirect_to(restaurant_reservations_path(restaurant))
        follow_redirect!
        expect(response.body).to include("Reservation cannot be rejected from its current state.")
      end
    end
  end
end
