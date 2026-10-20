require "rails_helper"

RSpec.describe "Admin client accessible products API" do
  let(:headers) { { "Authorization" => "Bearer #{JwtService.encode(create(:admin))}" } }
  let(:target_client) { create(:client) }
  let(:first_product) { create(:product) }
  let(:second_product) { create(:product) }

  describe "GET /api/v1/admin/clients/:client_id/client_accessible_products" do
    it "lists assigned products" do
      target_client.accessible_products << first_product

      get "/api/v1/admin/clients/#{target_client.id}/client_accessible_products", headers: headers

      expect(response.parsed_body.pluck("id")).to eq([first_product.id])
    end
  end

  describe "PUT /api/v1/admin/clients/:client_id/client_accessible_products" do
    it "assigns products" do
      put "/api/v1/admin/clients/#{target_client.id}/client_accessible_products",
          params: { product_ids: [first_product.id, second_product.id] },
          headers: headers,
          as: :json

      expect(response.parsed_body.pluck("id")).to match_array([first_product.id, second_product.id])
    end

    context "when the audit log fails" do
      before do
        target_client
        first_product
        allow(AuditLog).to receive(:record).and_raise(ActiveRecord::ActiveRecordError)
      end

      it "keeps the previous products when the audit log fails" do
        begin
          target_client.accessible_product_ids = [first_product.id]
        rescue ActiveRecord::ActiveRecordError
          nil
        end

        expect(target_client.accessible_products.reload.ids).to eq([])
      end
    end

    it "records the assigned product ids" do
      put "/api/v1/admin/clients/#{target_client.id}/client_accessible_products",
          params: { product_ids: [first_product.id, second_product.id] },
          headers: headers,
          as: :json

      log = AuditLog.find_by!(action: "client_accessible_product.update")
      expect(log.after_values["product_ids"]).to eq([first_product.id, second_product.id].sort)
    end
  end
end
