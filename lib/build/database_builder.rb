module Build
  class DatabaseBuilder
    def run
      execute
    end

    private

    def execute
      reset_data
      create_users
    end

    def reset_data
      puts "Cleaning up database..."
      Restaurant.destroy_all
      User.destroy_all
      puts "All records deleted."
    end

    def create_users
      puts "Creating 10 users with restaurants and tables..."

      10.times do
        user = User.create!(
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          email: Faker::Internet.unique.email,
          phone_number: Faker::PhoneNumber.cell_phone_in_e164,
          age: rand(1..100),
          date_of_birth: Faker::Date.birthday(min_age: 1, max_age: 100),
          password: "rails@123",
          password_confirmation: "rails@123"
        )

        %w[open closed archived].each do |status|
          2.times do
            restaurant = user.restaurants.create!(
              name: Faker::Restaurant.name,
              description: Faker::Restaurant.description,
              location: Faker::Address.city,
              cuisine_type: Faker::Restaurant.type,
              rating: rand(1..5),
              status: status,
              note: Faker::Lorem.sentence,
              likes: rand(0..100)
            )

            20.times do |i|
              restaurant.tables.create!(
                table_number: i + 1,
                seating_capacity: rand(2..8),
                status: Table.statuses.keys.sample # e.g., "available", "occupied", "reserved"
              )
            end
          end
        end
      end

      User.create!(
        first_name: "Nelson",
        last_name: "Kolas",
        email: "nelson@gmail.com",
        password: "rails@123",
        role_type: :customer,
        status: :active
      )

      User.create!(
        first_name: "Jane",
        last_name: "Done",
        email: "staff@gmail.com",
        password: "rails@123",
        role_type: :staff,
        status: :active
      )

      puts "10 users created with restaurants (open/closed/archived), each with 20 tables."
    end
  end
end
