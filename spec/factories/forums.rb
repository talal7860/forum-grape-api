FactoryBot.define do
  factory :forum do
    title { Faker::Hobbit.thorins_company }
    description { Faker::Hobbit.quote }
    association :added_by, factory: :user
  end
end
