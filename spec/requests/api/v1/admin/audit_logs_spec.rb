require "rails_helper"

RSpec.describe "Admin Audit Logs API" do
  let!(:admin) { create(:admin) }
  let!(:client_user) { create(:client) }
  let(:admin_headers) { { "Authorization" => "Bearer #{JwtService.encode(admin)}" } }
  let(:client_headers) { { "Authorization" => "Bearer #{JwtService.encode(client_user)}" } }

  describe "GET /api/v1/admin/audit_logs" do
    before { AuditLog.delete_all }

    let!(:log1) do
      AuditLog.create!(
        user: admin,
        action: "brand.update",
        auditable_type: "Brand",
        auditable_id: 1,
        outcome: "success",
        created_at: 2.days.ago
      )
    end

    let!(:log2) do
      AuditLog.create!(
        user: client_user,
        action: "card.issue",
        auditable_type: "Card",
        auditable_id: 10,
        outcome: "success",
        created_at: 1.day.ago
      )
    end

    let!(:log3) do
      AuditLog.create!(
        user: client_user,
        action: "login.failed",
        outcome: "refused",
        metadata: { "reason" => "bad_password" },
        created_at: Time.current
      )
    end

    it "returns paginated audit logs ordered by newest first" do
      get "/api/v1/admin/audit_logs", headers: admin_headers

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["data"].length).to eq(3)
      expect(body["data"].first["id"]).to eq(log3.id)
      expect(body["meta"]).to eq("page" => 1, "per_page" => 25)
    end

    it "paginates results" do
      get "/api/v1/admin/audit_logs", params: { page: 2, per_page: 2 }, headers: admin_headers

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["data"].length).to eq(1)
      expect(body["data"].first["id"]).to eq(log1.id)
      expect(body["meta"]).to eq("page" => 2, "per_page" => 2)
    end

    it "filters by user_id" do
      get "/api/v1/admin/audit_logs", params: { user_id: client_user.id }, headers: admin_headers

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["data"].pluck("id")).to contain_exactly(log2.id, log3.id)
    end

    it "filters by log_action" do
      get "/api/v1/admin/audit_logs", params: { log_action: "brand.update" }, headers: admin_headers

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["data"].pluck("id")).to eq([log1.id])
    end

    it "filters by record_type" do
      get "/api/v1/admin/audit_logs", params: { record_type: "Card" }, headers: admin_headers

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["data"].pluck("id")).to eq([log2.id])
    end

    it "filters by date range" do
      from = 3.days.ago.to_date.to_s
      to = 2.days.ago.to_date.to_s

      get "/api/v1/admin/audit_logs", params: { from: from, to: to }, headers: admin_headers

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["data"].pluck("id")).to eq([log1.id])
    end

    it "returns bad request for invalid date format" do
      get "/api/v1/admin/audit_logs", params: { from: "invalid-date" }, headers: admin_headers

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body).to eq("error" => "Invalid date format")
    end

    it "returns forbidden for non-admin clients" do
      get "/api/v1/admin/audit_logs", headers: client_headers

      expect(response).to have_http_status(:forbidden)
    end

    it "returns unauthorized when unauthenticated" do
      get "/api/v1/admin/audit_logs"

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
