FactoryBot.define do
  factory :table do
    table_number { 1 }
    seating_capacity { 1 }
    status { 1 }
    restaurant { nil }
  end
end
