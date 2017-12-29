FactoryBot.define do
  factory :post do
    content { Faker::Lorem.paragraph }
    association :added_by, factory: :user
    association :topic, factory: :topic
  end
end
