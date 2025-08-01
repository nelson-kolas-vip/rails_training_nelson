FactoryBot.define do
  factory :menu do
    item_name { "MyString" }
    description { "MyText" }
    price { "9.99" }
    category { "MyString" }
    available { false }
    restaurant { nil }
  end
end
