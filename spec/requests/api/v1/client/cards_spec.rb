require "rails_helper"

RSpec.describe "Client Cards API" do
  let(:client) { create(:client, payout_rate: 12.5) }
  let(:headers) { { "Authorization" => "Bearer #{JwtService.encode(client)}" } }
  let(:product) { create(:product, brand: create(:brand), price_value: 50_000) }

  before { client.accessible_products << product }

  it "issues a card" do
    post "/api/v1/client/cards",
         params: { product_id: product.id, activation_number: "0000000000000001" },
         headers: headers,
         as: :json

    expect(response).to have_http_status(:created)
    expect(response.parsed_body).to include("price_value" => 50_000, "payout_rate" => "12.5", "status" => "issued")
    expect(response.parsed_body.keys).not_to include("pin")
  end

  it "returns the same card when the activation number is reused" do
    params = { product_id: product.id, activation_number: "0000000000000001" }

    post "/api/v1/client/cards", params:, headers:, as: :json
    id = response.parsed_body["id"]

    post "/api/v1/client/cards", params:, headers:, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["id"]).to eq(id)
  end

  it "stores the activation number from the request" do
    post "/api/v1/client/cards",
         params: { product_id: product.id, activation_number: "0000000000000099" },
         headers: headers,
         as: :json

    expect(response.parsed_body["activation_number"]).to eq("0000000000000099")
  end

  it "refuses a product the client cannot access" do
    other = create(:product, brand: create(:brand), price_value: 20_000)

    post "/api/v1/client/cards",
         params: { product_id: other.id, activation_number: "0000000000000002" },
         headers: headers,
         as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body["error"]).to eq("Product not found or not accessible")
  end
end
