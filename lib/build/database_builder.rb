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
      User.destroy_all
      puts "All records deleted."
    end

    def create_users
      puts "Creating 10 users..."
      10.times do
        User.create!(
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          email: Faker::Internet.unique.email,
          phone_number: Faker::PhoneNumber.cell_phone_in_e164,
          age: rand(1..100),
          date_of_birth: Faker::Date.birthday(min_age: 1, max_age: 100),
          password: "rails@123",
          password_confirmation: "rails@123"
        )
      end
      puts "10 users created."
    end
  end
end
