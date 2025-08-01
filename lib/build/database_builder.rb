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
      Table.destroy_all
      Menu.destroy_all
      User.destroy_all
      puts "All records deleted."
    end

    def create_users
      puts "Creating 10 users with restaurants, tables, and menus..."

      10.times do |user_index|
        user = User.create!(
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          email: Faker::Internet.unique.email,
          phone_number: Faker::PhoneNumber.cell_phone_in_e164,
          age: rand(1..100),
          date_of_birth: Faker::Date.birthday(min_age: 1, max_age: 100),
          password: "rails@123",
          password_confirmation: "rails@123",
          role_type: :staff,
          status: :active
        )

        puts "Created User ##{user_index + 1} - #{user.email}"

        %w[open closed archived].each do |status|
          2.times do |i|
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

            puts "Created Restaurant '#{restaurant.name}' (#{status}) for #{user.email}"

            20.times do |t_index|
              restaurant.tables.create!(
                table_number: t_index + 1,
                seating_capacity: rand(2..8),
                status: Table.statuses.keys.sample
              )
            end

            20.times do |m_index|
              category = ["starter", "main course", "dessert", "drink"].sample

              veg_status =
                case category
                when "dessert", "drink"
                  :veg
                when "starter", "main course"
                  # For starters and mains, decide based on a probability
                  # e.g., 60% veg, 40% non_veg
                  rand < 0.6 ? :veg : :non_veg
                end

              restaurant.menus.create!(
                item_name: Faker::Food.dish,
                description: Faker::Food.description,
                price: rand(10..100),
                category: category,
                available: [true, false].sample,
                veg_status: Menu.veg_statuses[veg_status]
              )
            end
          end
        end
      end

      puts "Creating sample users for login testing..."

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

      puts "Seeding complete: 10 users, 60 restaurants, 1200 tables, 1200 menus."
    end
  end
end
