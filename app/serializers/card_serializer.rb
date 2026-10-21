class CardSerializer
  include Alba::Resource

  attributes :id, :client_id, :product_id, :activation_number, :status, :price_value,
             :issued_at, :cancelled_at, :created_at, :updated_at

  attribute :payout_rate do |card|
    card.payout_rate.to_s
  end
end
