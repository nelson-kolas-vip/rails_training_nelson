FactoryBot.define do
  factory :user do
    first_name     { Faker::Name.first_name }
    last_name      { Faker::Name.last_name }
    email          { Faker::Internet.unique.email }
    phone_number   { Faker::PhoneNumber.cell_phone_in_e164 }
    age            { 1..100 }
    date_of_birth  { Faker::Date.birthday(min_age: 18, max_age: 60) }
    password       { 'rails@123' }
    password_confirmation { 'rails@123' }
  end
end
