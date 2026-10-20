require "rails_helper"

RSpec.describe "Admin audit logs API" do
  let(:headers) { { "Authorization" => "Bearer #{JwtService.encode(create(:admin))}" } }
  let(:admin) { create(:admin) }

  describe "GET /api/v1/admin/audit_logs" do
    context "with two logs" do
      before do
        @older = AuditLog.record(action: "brand.create")
        @newer = AuditLog.record(action: "brand.update")
      end

      it "lists the newest log first" do
        get "/api/v1/admin/audit_logs", headers: headers

        expect(response.parsed_body["audit_logs"].pluck("id")).to eq([@newer.id, @older.id])
      end
    end

    context "with logs from two users" do
      before do
        Current.set(user: admin) { AuditLog.record(action: "login.success") }
        AuditLog.record(action: "login.failed", outcome: :refused)
      end

      it "filters by user" do
        get "/api/v1/admin/audit_logs", params: { user_id: admin.id }, headers: headers

        expect(response.parsed_body["audit_logs"].pluck("user_id")).to eq([admin.id])
      end
    end

    context "with two actions" do
      before do
        AuditLog.record(action: "brand.create")
        AuditLog.record(action: "brand.update")
      end

      it "filters by action" do
        get "/api/v1/admin/audit_logs", params: { action: "brand.update" }, headers: headers

        expect(response.parsed_body["audit_logs"].pluck("action")).to eq(["brand.update"])
      end
    end

    context "with a brand" do
      before { @brand = create(:brand, name: "Logged") }

      it "filters by record type" do
        get "/api/v1/admin/audit_logs", params: { record_type: "Brand" }, headers: headers

        expect(response.parsed_body["audit_logs"].pluck("auditable_id")).to eq([@brand.id])
      end
    end

    context "with logs in January and March" do
      before do
        AuditLog.insert_all!([
          { action: "old.day", outcome: "success", metadata: {}, created_at: Time.utc(2026, 1, 2, 12) },
          { action: "new.day", outcome: "success", metadata: {}, created_at: Time.utc(2026, 3, 2, 12) }
        ])
      end

      it "filters by date" do
        get "/api/v1/admin/audit_logs", params: { from: "2026-03-01", to: "2026-03-31" }, headers: headers

        expect(response.parsed_body["audit_logs"].pluck("action")).to eq(["new.day"])
      end
    end

    context "with three logs" do
      before { 3.times { |n| AuditLog.record(action: "page.#{n}") } }

      it "returns the second page" do
        get "/api/v1/admin/audit_logs", params: { page: 2, per_page: 2 }, headers: headers

        expect(response.parsed_body["audit_logs"].size).to eq(1)
      end
    end

    context "when the caller is a client" do
      before { @client_headers = { "Authorization" => "Bearer #{JwtService.encode(create(:client))}" } }

      it "rejects a client" do
        get "/api/v1/admin/audit_logs", headers: @client_headers

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "with a bad date" do
      it "rejects the date" do
        get "/api/v1/admin/audit_logs", params: { from: "nope" }, headers: headers

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
