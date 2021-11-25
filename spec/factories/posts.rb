FactoryBot.define do
  factory :post do
    association :user, factory: :user
    title { Faker::Book.title }
    content { Faker::Sports::Football.player }

    trait :invalid do
      title { nil }
      content { nil }
    end
  end
end
