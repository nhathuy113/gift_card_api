require "rails_helper"

RSpec.describe "Admin client accessible products API" do
  let(:headers) { { "Authorization" => "Bearer #{JwtService.encode(create(:admin))}" } }
  let(:client) { create(:client) }
  let(:product_a) { create(:product) }
  let(:product_b) { create(:product) }

  describe "GET /api/v1/admin/clients/:client_id/client_accessible_products" do
    it "lists assigned products" do
      client.accessible_products << product_a

      get "/api/v1/admin/clients/#{client.id}/client_accessible_products", headers: headers

      expect(response.parsed_body.pluck("id")).to eq([product_a.id])
    end
  end

  describe "PUT /api/v1/admin/clients/:client_id/client_accessible_products" do
    it "assigns products" do
      put "/api/v1/admin/clients/#{client.id}/client_accessible_products",
          params: { product_ids: [product_a.id, product_b.id] },
          headers: headers,
          as: :json

      expect(response.parsed_body.pluck("id")).to match_array([product_a.id, product_b.id])
    end

    it "records the assigned product ids" do
      put "/api/v1/admin/clients/#{client.id}/client_accessible_products",
          params: { product_ids: [product_a.id, product_b.id] },
          headers: headers,
          as: :json

      log = AuditLog.find_by!(action: "client_accessible_product.update")
      expect(log.after_values["product_ids"]).to eq([product_a.id, product_b.id].sort)
    end
  end
end
