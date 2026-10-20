FactoryBot.define do
  factory :card do
    client
    product
    sequence(:activation_number) { |n| format("%016d", n) }
    pin { "123456" }
    status { "issued" }
    price_value { 50_000 }
    payout_rate { 12.5 }
    issued_at { Time.current }

    trait :cancelled do
      status { "cancelled" }
      cancelled_at { Time.current }
    end
  end
end
