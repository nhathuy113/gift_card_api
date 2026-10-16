FactoryBot.define do
  factory :card do
    client
    product
    sequence(:activation_number) { |n| "ACT#{n.to_s.rjust(13, '0')}" }
    pin { "123456" }
    status { "issued" }
    price_value { 50_000 }
    payout_rate { 12.5 }
    sequence(:idempotency_key) { |n| "key-#{n}" }
    issued_at { Time.current }

    trait :cancelled do
      status { "cancelled" }
      cancelled_at { Time.current }
    end
  end
end
