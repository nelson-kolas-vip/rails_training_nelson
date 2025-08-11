FactoryBot.define do
  factory :order do
    user { nil }
    restaurant { nil }
    items { "" }
    total_price { "9.99" }
  end
end
