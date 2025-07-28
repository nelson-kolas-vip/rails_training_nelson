FactoryBot.define do
  factory :restaurant do
    name { Faker::Restaurant.name }
    description { Faker::Restaurant.description }
    location { Faker::Address.city }
    cuisine_type { Faker::Restaurant.type }
    user
  end
end
