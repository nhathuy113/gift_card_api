require "rails_helper"

RSpec.describe Cards::Issue do
  let(:client) { create(:client, payout_rate: 15.0) }
  let(:product) { create(:product, price_value: 100_000) }

  before { client.accessible_products << product }

  it "issues a card" do
    result = described_class.call(client:, product_id: product.id, activation_number: "0000000000000001")

    expect(result.created?).to be(true)
    expect(result.card.price_value).to eq(100_000)
    expect(result.card.payout_rate).to eq(15.0)
  end

  it "returns the same card for the same key" do
    first = described_class.call(client:, product_id: product.id, activation_number: "0000000000000001")
    again = described_class.call(client:, product_id: product.id, activation_number: "0000000000000001")

    expect(again.created?).to be(false)
    expect(again.card.id).to eq(first.card.id)
  end
end
