FactoryBot.define do
  factory :table do
    table_number { Faker::Number.between(from: 1, to: 20) }
    seating_capacity { Faker::Number.between(from: 1, to: 8) }
    status { [:available, :occupied, :reserved].sample }
    association :restaurant
  end
end
