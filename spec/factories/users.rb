FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    username { Faker::Internet.email }
    email { Faker::Internet.email }
    avatar { Faker::Avatar.image }
    phone_number { Faker::PhoneNumber.cell_phone }
    password 'password'
    password_confirmation 'password'
    factory :admin do
      after(:create) do |user|
        user.add_role :admin
      end
    end
  end
end
