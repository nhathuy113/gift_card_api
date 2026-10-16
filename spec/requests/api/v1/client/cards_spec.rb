require "rails_helper"

RSpec.describe "Client Cards API" do
  let(:client) { create(:client, payout_rate: 12.5) }
  let(:headers) { { "Authorization" => "Bearer #{JwtService.encode(client)}" } }
  let(:product) { create(:product, :active, brand: create(:brand, :active), price_value: 50_000) }

  before { client.accessible_products << product }

  it "lists this client's cards" do
    card = create(:card, client:, product:)

    get "/api/v1/client/cards", headers: headers

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.pluck("id")).to eq([ card.id ])
    expect(response.parsed_body.first.keys).not_to include("pin", "idempotency_key")
  end

  it "shows a card" do
    card = create(:card, client:, product:)

    get "/api/v1/client/cards/#{card.id}", headers: headers

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include("id" => card.id, "status" => "issued")
  end

  it "issues a card" do
    post "/api/v1/client/cards",
         params: { product_id: product.id, idempotency_key: "k1" },
         headers: headers,
         as: :json

    expect(response).to have_http_status(:created)
    expect(response.parsed_body).to include("price_value" => 50_000, "payout_rate" => "12.5", "status" => "issued")
    expect(response.parsed_body.keys).not_to include("pin", "idempotency_key")
  end

  it "returns the same card when the key is reused" do
    params = { product_id: product.id, idempotency_key: "k1" }

    post "/api/v1/client/cards", params:, headers:, as: :json
    id = response.parsed_body["id"]

    post "/api/v1/client/cards", params:, headers:, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["id"]).to eq(id)
  end

  it "cancels a card" do
    card = create(:card, client:, product:)

    post "/api/v1/client/cards/#{card.id}/cancel", headers: headers

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["status"]).to eq("cancelled")
  end
end
