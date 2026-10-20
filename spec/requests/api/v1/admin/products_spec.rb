require "rails_helper"

RSpec.describe "Admin Products API" do
  let(:headers) { { "Authorization" => "Bearer #{JwtService.encode(create(:admin))}" } }
  let(:brand) { create(:brand) }

  describe "GET /api/v1/admin/brands/:brand_id/products" do
    let!(:product) { create(:product, brand: brand, name: "Card 50k") }
    let!(:other_product) { create(:product, name: "Card 100k") }

    it "lists products of the brand" do
      get "/api/v1/admin/brands/#{brand.id}/products", headers: headers

      expect(response.parsed_body.pluck("id")).to eq([product.id])
    end
  end

  describe "POST /api/v1/admin/brands/:brand_id/products" do
    it "creates a product" do
      post "/api/v1/admin/brands/#{brand.id}/products",
           params: { name: "Voucher 100k", price_value: 100_000 },
           headers: headers,
           as: :json

      expect(response.parsed_body).to include("name" => "Voucher 100k", "price_value" => 100_000, "state" => "active")
    end
  end

  describe "GET /api/v1/admin/products/:id" do
    let(:product) { create(:product, brand: brand, name: "Card 50k") }

    it "shows the product" do
      get "/api/v1/admin/products/#{product.id}", headers: headers

      expect(response.parsed_body).to include("id" => product.id, "name" => "Card 50k")
    end
  end

  describe "PATCH /api/v1/admin/products/:id" do
    let(:product) { create(:product, brand: brand, name: "Initial", price_value: 50_000) }

    it "updates the product" do
      patch "/api/v1/admin/products/#{product.id}",
            params: { name: "Renamed", price_value: 75_000 },
            headers: headers,
            as: :json

      expect(response.parsed_body).to include("name" => "Renamed", "price_value" => 75_000)
    end
  end

  describe "PATCH /api/v1/admin/products/:id/state" do
    let(:product) { create(:product, brand: brand, state: "active") }

    it "changes the product to inactive" do
      patch "/api/v1/admin/products/#{product.id}/state", params: { state: "inactive" }, headers: headers, as: :json

      expect(response.parsed_body["state"]).to eq("inactive")
    end
  end

  describe "DELETE /api/v1/admin/products/:id" do
    let(:product) { create(:product, brand: brand) }

    it "deletes the product" do
      delete "/api/v1/admin/products/#{product.id}", headers: headers

      expect(response).to have_http_status(:no_content)
    end
  end
end
