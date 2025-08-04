FactoryBot.define do
  factory :user do
    first_name     { Faker::Name.first_name }
    last_name      { Faker::Name.last_name }
    email          { Faker::Internet.unique.email }
    password       { "password123" }
    age            { rand(18..60) }
    date_of_birth  { Faker::Date.birthday(min_age: 18, max_age: 60) }
    phone_number   { Faker::PhoneNumber.cell_phone_in_e164 }
    role_type      { rand(2..3) }

    factory :staff_user do
      role_type { 2 }
    end

    factory :customer_user do
      role_type { 3 }
    end
  end
end
