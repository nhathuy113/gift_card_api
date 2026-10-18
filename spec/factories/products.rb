FactoryBot.define do
  factory :product do
    brand
    sequence(:name) { |n| "Product #{n}" }
    price_value { 50_000 }
    state { "active" }
    custom_fields { [] }

    trait :inactive do
      state { "inactive" }
    end
  end
end
