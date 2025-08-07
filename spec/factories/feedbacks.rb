FactoryBot.define do
  factory :feedback do
    rating { Faker::Number.between(from: 1, to: 5) }
    comment { Faker::Lorem.paragraph(sentence_count: 3) }
    customer_name { Faker::Name.name }
    association :restaurant, factory: :restaurant, strategy: :build, optional: true
    association :user, factory: :customer_user
    current_user_url { Faker::Internet.url }
  end
end
