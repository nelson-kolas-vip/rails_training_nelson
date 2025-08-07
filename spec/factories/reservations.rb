FactoryBot.define do
  factory :reservation do
    reservation_date { Faker::Date.forward(days: 30) }
    reservation_time { Time.zone.parse("#{Faker::Number.between(from: 9, to: 21)}:00") }
    number_of_guests { Faker::Number.between(from: 1, to: 8) }
    customer_name { Faker::Name.name }
    customer_contact { Faker::Internet.email }
    status { :pending }
    association :restaurant
    association :table
    association :user, factory: :customer_user
  end
end
