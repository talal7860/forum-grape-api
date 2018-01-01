avatars = Dir[Rails.root.join('spec', 'factories', 'avatars', '*.png').to_s].map{|file| File.open file}
FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    username { Faker::Internet.email }
    email { Faker::Internet.email }
    avatar { avatars.sample }
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
