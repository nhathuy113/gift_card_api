require "rails_helper"

RSpec.describe "Admin reports API" do
  let(:headers) { { "Authorization" => "Bearer #{JwtService.encode(create(:admin))}" } }
  let(:brand) { create(:brand, name: "Starbucks") }
  let(:product) { create(:product, brand:, price_value: 50_000) }
  let(:client) { create(:client, email: "a@example.com", payout_rate: 12.5) }
  let!(:issued_card) do
    create(:card, client:, product:, price_value: 50_000, payout_rate: 12.5, issued_at: Time.zone.parse("2026-10-01"))
  end
  let!(:cancelled_card) do
    create(:card, :cancelled, client:, product:, price_value: 20_000, payout_rate: 12.5,
                              issued_at: Time.zone.parse("2026-10-02"), cancelled_at: Time.zone.parse("2026-10-03"))
  end
  let!(:older_card) do
    create(:card, client: create(:client, email: "b@example.com"), product:, price_value: 10_000, payout_rate: 10,
                  issued_at: Time.zone.parse("2026-09-01"))
  end

  describe "GET /api/v1/admin/reports/brands" do
    it "totals cards for each brand in the date range" do
      get "/api/v1/admin/reports/brands", params: { from: "2026-10-01", to: "2026-10-31" }, headers: headers

      expect(response.parsed_body).to eq([
        {
          "brand_id" => brand.id,
          "name" => "Starbucks",
          "issued_count" => 2,
          "issued_total_value" => 70_000,
          "payout_total_value" => 8750.0,
          "cancelled_count" => 1,
          "cancelled_total_value" => 20_000
        }
      ])
    end

    context "without dates" do
      let!(:today_card) do
        create(:card, client:, product:, price_value: 30_000, payout_rate: 12.5, issued_at: Time.current)
      end

      it "totals cards for today" do
        get "/api/v1/admin/reports/brands", headers: headers

        expect(response.parsed_body).to eq([
          {
            "brand_id" => brand.id,
            "name" => "Starbucks",
            "issued_count" => 1,
            "issued_total_value" => 30_000,
            "payout_total_value" => 3750.0,
            "cancelled_count" => 0,
            "cancelled_total_value" => 0
          }
        ])
      end
    end

    context "with a bad date" do
      it "rejects the date" do
        get "/api/v1/admin/reports/brands", params: { from: "nope" }, headers: headers

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe "GET /api/v1/admin/reports/clients" do
    it "totals cards for each client in the date range" do
      get "/api/v1/admin/reports/clients", params: { from: "2026-10-01", to: "2026-10-31" }, headers: headers

      expect(response.parsed_body).to eq([
        {
          "client_id" => client.id,
          "email" => "a@example.com",
          "issued_count" => 2,
          "issued_total_value" => 70_000,
          "payout_total_value" => 8750.0,
          "cancelled_count" => 1,
          "cancelled_total_value" => 20_000
        }
      ])
    end
  end
end
