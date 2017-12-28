FactoryBot.define do
  factory :topic do
    title { Faker::Hobbit.thorins_company }
    description { Faker::Lorem.paragraph }
    association :added_by, factory: :user
    association :forum, factory: :forum
  end
end
