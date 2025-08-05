class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :reservations do |t|
      t.date :reservation_date
      t.time :reservation_time
      t.integer :number_of_guests
      t.string :customer_name
      t.string :customer_contact
      t.references :restaurant, null: false, foreign_key: true
      t.references :table, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
