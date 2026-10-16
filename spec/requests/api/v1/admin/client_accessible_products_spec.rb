require "rails_helper"

RSpec.describe "Admin client accessible products API" do
  let(:client) { create(:client) }
  let(:headers) { { "Authorization" => "Bearer #{JwtService.encode(create(:admin))}" } }
  let(:product_a) { create(:product) }
  let(:product_b) { create(:product) }

  it "lists assigned products" do
    client.accessible_products << product_a

    get "/api/v1/admin/clients/#{client.id}/client_accessible_products", headers: headers

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.pluck("id")).to eq([ product_a.id ])
  end

  it "assigns products" do
    put "/api/v1/admin/clients/#{client.id}/client_accessible_products",
        params: { product_ids: [ product_a.id, product_b.id ] },
        headers: headers,
        as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.pluck("id")).to match_array([ product_a.id, product_b.id ])
  end
end
