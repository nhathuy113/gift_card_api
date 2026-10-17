FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "password123" }
    state { "active" }
    role { "client" }
    payout_rate { 15.0 }

    trait :inactive do
      state { "inactive" }
    end
  end
end
