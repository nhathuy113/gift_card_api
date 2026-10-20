require "rails_helper"

RSpec.describe "GET /api/v1/client/reports" do
  let(:client) { create(:client, email: "a@example.com", payout_rate: 12.5) }
  let(:headers) { { "Authorization" => "Bearer #{JwtService.encode(client)}" } }
  let(:product) { create(:product, brand: create(:brand), price_value: 50_000) }
  let!(:issued_card) do
    create(:card, client:, product:, price_value: 50_000, payout_rate: 12.5, issued_at: Time.zone.parse("2026-10-01"))
  end
  let!(:cancelled_card) do
    create(:card, :cancelled, client:, product:, price_value: 20_000, payout_rate: 12.5,
                              issued_at: Time.zone.parse("2026-10-02"), cancelled_at: Time.zone.parse("2026-10-03"))
  end
  let!(:other_client_card) do
    create(:card, client: create(:client, email: "b@example.com"), product:, price_value: 10_000, payout_rate: 10,
                  issued_at: Time.zone.parse("2026-10-04"))
  end

  it "totals the current client's spending in the date range" do
    get "/api/v1/client/reports", params: { from: "2026-10-01", to: "2026-10-31" }, headers: headers

    expect(response.parsed_body).to eq(
      "issued_count" => 2,
      "issued_total" => 70_000,
      "payout_total" => 8750.0,
      "cancelled_count" => 1,
      "cancelled_total" => 20_000
    )
  end
end
