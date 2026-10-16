require "rails_helper"

RSpec.describe "Admin Products API" do
  let(:headers) { { "Authorization" => "Bearer #{JwtService.encode(create(:admin))}" } }
  let(:brand) { create(:brand) }

  it "lists products of a brand" do
    product = create(:product, brand: brand, name: "Card 50k")
    create(:product, name: "Card 100k")

    get "/api/v1/admin/brands/#{brand.id}/products", headers: headers

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.pluck("id")).to eq([ product.id ])
  end

  it "creates a product" do
    post "/api/v1/admin/brands/#{brand.id}/products",
         params: { name: "Voucher 100k", price_value: 100_000 },
         headers: headers,
         as: :json

    expect(response).to have_http_status(:created)
    expect(response.parsed_body).to include(
      "brand_id" => brand.id,
      "name" => "Voucher 100k",
      "price_value" => 100_000,
      "state" => "active"
    )
  end

  it "updates a product" do
    product = create(:product, brand: brand, name: "Initial", price_value: 50_000)

    patch "/api/v1/admin/products/#{product.id}",
          params: { name: "Renamed", price_value: 75_000 },
          headers: headers,
          as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include("name" => "Renamed", "price_value" => 75_000)
  end

  it "changes product state" do
    product = create(:product, brand: brand, state: "active")

    patch "/api/v1/admin/products/#{product.id}/state",
          params: { state: "inactive" },
          headers: headers,
          as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["state"]).to eq("inactive")
  end

  it "deletes a product" do
    product = create(:product, brand: brand)

    delete "/api/v1/admin/products/#{product.id}", headers: headers

    expect(response).to have_http_status(:no_content)
  end
end
