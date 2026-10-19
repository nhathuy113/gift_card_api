require "rails_helper"

RSpec.describe "Client Products API" do
  let(:client) { create(:client) }
  let(:headers) { { "Authorization" => "Bearer #{JwtService.encode(client)}" } }
  let(:brand) { create(:brand, :active, name: "Starbucks") }
  let(:product) { create(:product, brand: brand, name: "Coffee 50k", state: "active") }

  before { client.accessible_products << product }

  it "lists assigned products" do
    client.accessible_products << create(:product, brand: brand, name: "Tea 20k", state: "inactive")

    get "/api/v1/client/products", headers: headers

    expect(response.parsed_body.pluck("name")).to eq(["Coffee 50k", "Tea 20k"])
  end

  it "filters by brand" do
    client.accessible_products << create(:product, brand: create(:brand, :active), name: "Cinema 50k")

    get "/api/v1/client/products", params: { brand_id: brand.id }, headers: headers

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.pluck("id")).to eq([ product.id ])
  end

  it "filters by name" do
    client.accessible_products << create(:product, brand: brand, name: "Matcha Latte")

    get "/api/v1/client/products", params: { q: "coffee" }, headers: headers

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.pluck("id")).to eq([ product.id ])
  end
end
