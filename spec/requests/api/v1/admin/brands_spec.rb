require "rails_helper"

RSpec.describe "Admin Brands API" do
  let(:headers) { { "Authorization" => "Bearer #{JwtService.encode(create(:admin))}" } }

  describe "GET /api/v1/admin/brands" do
    let!(:zara) { create(:brand, name: "Zara") }
    let!(:apple) { create(:brand, name: "Apple") }

    it "lists brands by name" do
      get "/api/v1/admin/brands", headers: headers

      expect(response.parsed_body.pluck("name")).to eq(["Apple", "Zara"])
    end
  end

  describe "GET /api/v1/admin/brands/:id" do
    let(:brand) { create(:brand, name: "Uniqlo") }

    it "shows a brand" do
      get "/api/v1/admin/brands/#{brand.id}", headers: headers

      expect(response.parsed_body).to include("id" => brand.id, "name" => "Uniqlo")
    end
  end

  describe "POST /api/v1/admin/brands" do
    it "creates a brand" do
      post "/api/v1/admin/brands", params: { name: "Starbucks" }, headers: headers, as: :json

      expect(response.parsed_body).to include("name" => "Starbucks", "state" => "active")
    end
  end

  describe "PATCH /api/v1/admin/brands/:id" do
    let(:brand) { create(:brand, name: "Old Name") }

    it "updates the name" do
      patch "/api/v1/admin/brands/#{brand.id}", params: { name: "New Name" }, headers: headers, as: :json

      expect(response.parsed_body["name"]).to eq("New Name")
    end
  end

  describe "PATCH /api/v1/admin/brands/:id/state" do
    let(:brand) { create(:brand, state: "active") }

    it "changes the brand to inactive" do
      patch "/api/v1/admin/brands/#{brand.id}/state", params: { state: "inactive" }, headers: headers, as: :json

      expect(response.parsed_body["state"]).to eq("inactive")
    end
  end
end
