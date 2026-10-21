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

  it "refuses an inactive product" do
    product.update!(state: "inactive")

    post "/api/v1/client/cards",
         params: { product_id: product.id, activation_number: "0000000000000003" },
         headers: headers,
         as: :json

    expect(response.parsed_body["error"]).to eq("Product is not available")
  end

  it "refuses a product from an inactive brand" do
    product.brand.update!(state: "inactive")

    post "/api/v1/client/cards",
         params: { product_id: product.id, activation_number: "0000000000000004" },
         headers: headers,
         as: :json

    expect(response.parsed_body["error"]).to eq("Product is not available")
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

RSpec.describe "POST /api/v1/client/cards/cancel" do
  let(:client) { create(:client) }
  let(:headers) { { "Authorization" => "Bearer #{JwtService.encode(client)}" } }
  let(:card) { create(:card, client:) }

  it "cancels an issued card" do
    post "/api/v1/client/cards/cancel",
         params: { activation_number: card.activation_number },
         headers: headers,
         as: :json

    expect(response.parsed_body.slice("id", "status")).to eq("id" => card.id, "status" => "cancelled")
  end

  it "records the cancel" do
    post "/api/v1/client/cards/cancel",
         params: { activation_number: card.activation_number },
         headers: headers,
         as: :json

    expect(AuditLog.order(:id).last.action).to eq("card.cancel")
  end

  context "when the card is already cancelled" do
    let(:card) { create(:card, :cancelled, client:) }

    it "refuses the cancel" do
      post "/api/v1/client/cards/cancel",
           params: { activation_number: card.activation_number },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "records the refused cancel" do
      post "/api/v1/client/cards/cancel",
           params: { activation_number: card.activation_number },
           headers: headers,
           as: :json

      expect(AuditLog.order(:id).last.outcome).to eq("refused")
    end
  end

  context "when the card belongs to another client" do
    let(:card) { create(:card) }

    it "returns not found" do
      post "/api/v1/client/cards/cancel",
           params: { activation_number: card.activation_number },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
