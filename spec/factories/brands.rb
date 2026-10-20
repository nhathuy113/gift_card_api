FactoryBot.define do
  factory :brand do
    sequence(:name) { |n| "Brand #{n}" }
    state { "active" }
    custom_fields { [] }

    trait :active do
      state { "active" }
    end

    trait :inactive do
      state { "inactive" }
    end
  end
end
