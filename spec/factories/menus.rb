FactoryBot.define do
  factory :menu do
    item_name { Faker::Food.dish }
    description { Faker::Food.description }
    price { Faker::Commerce.price(range: 5.0..50.0) }
    category { Faker::Food.ethnic_category }
    available { [true, false].sample }
    veg_status { Menu.veg_statuses.keys.sample }
    association :restaurant
    association :user
  end
end
