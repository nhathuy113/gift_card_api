require "rails_helper"

RSpec.describe "Admin Brands API" do
  let(:headers) { { "Authorization" => "Bearer #{JwtService.encode(create(:admin))}" } }

  it "lists brands" do
    create(:brand, name: "Zara")
    create(:brand, name: "Apple")

    get "/api/v1/admin/brands", headers: headers

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.pluck("name")).to eq([ "Apple", "Zara" ])
  end

  it "shows a brand" do
    brand = create(:brand, name: "Uniqlo")

    get "/api/v1/admin/brands/#{brand.id}", headers: headers

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include("id" => brand.id, "name" => "Uniqlo")
  end

  it "creates a brand" do
    post "/api/v1/admin/brands",
         params: { name: "Starbucks" },
         headers: headers,
         as: :json

    expect(response).to have_http_status(:created)
    expect(response.parsed_body).to include("name" => "Starbucks", "state" => "active")
  end

  it "updates a brand" do
    brand = create(:brand, name: "Old Name")

    patch "/api/v1/admin/brands/#{brand.id}", params: { name: "New Name" }, headers: headers, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["name"]).to eq("New Name")
  end

  it "changes brand state" do
    brand = create(:brand, state: "active")

    patch "/api/v1/admin/brands/#{brand.id}/state", params: { state: "inactive" }, headers: headers, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["state"]).to eq("inactive")
  end
end
