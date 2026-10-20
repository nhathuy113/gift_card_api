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

  it "records the issue without a pin" do
    described_class.call(client:, product_id: product.id, activation_number: "0000000000000001")

    expect(AuditLog.last.attributes.slice("action", "after_values")).to eq(
      "action" => "card.issue",
      "after_values" => {
        "product_id" => product.id,
        "price_value" => 100_000,
        "payout_rate" => "15.0"
      }
    )
  end

  it "records a refused issue" do
    expect {
      described_class.call(client:, product_id: create(:product).id, activation_number: "0000000000000002")
    }.to raise_error(Cards::Issue::Ineligible)
      .and change { AuditLog.refused.where(action: "card.issue").count }.by(1)
  end

  it "drops the card when recording the issue fails" do
    allow(AuditLog).to receive(:record).and_raise(ActiveRecord::ActiveRecordError)

    expect {
      described_class.call(client:, product_id: product.id, activation_number: "0000000000000001")
    }.to raise_error(ActiveRecord::ActiveRecordError)
      .and change(Card, :count).by(0)
  end

  it "returns the same card for the same key" do
    first = described_class.call(client:, product_id: product.id, activation_number: "0000000000000001")
    again = described_class.call(client:, product_id: product.id, activation_number: "0000000000000001")

    expect(again.created?).to be(false)
    expect(again.card.id).to eq(first.card.id)
  end
end
