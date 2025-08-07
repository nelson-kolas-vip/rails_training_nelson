FactoryBot.define do
  factory :restaurant do
    name { Faker::Restaurant.name }
    description { Faker::Restaurant.description }
    location { Faker::Address.city }
    cuisine_type { Faker::Restaurant.type }
    rating { rand(1.0..5.0).round(1) }
    status { :open }
    note { Faker::Lorem.sentence }
    likes { rand(0..100) }
    association :user, factory: :staff_user
  end
end
