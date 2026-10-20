require "rails_helper"

RSpec.describe "Admin clients API" do
  let(:headers) { { "Authorization" => "Bearer #{JwtService.encode(create(:admin))}" } }
  let(:payload) { { email: "new-client@example.com", password: "secret123", payout_rate: 12.5 } }

  it "creates a client" do
    post "/api/v1/admin/clients", params: payload, headers: headers, as: :json

    expect(response).to have_http_status(:created)
    expect(response.parsed_body).to include(
      "email" => "new-client@example.com",
      "role" => "client",
      "state" => "active",
      "payout_rate" => 12.5
    )
    expect(response.parsed_body.keys).to eq(%w[id email role state payout_rate])
  end

  it "omits password and password_digest" do
    post "/api/v1/admin/clients", params: payload, headers: headers, as: :json

    expect(response.parsed_body.keys).not_to include("password", "password_digest")
  end

  it "records the new client" do
    post "/api/v1/admin/clients", params: payload, headers: headers, as: :json

    expect(AuditLog.last.action).to eq("client.create")
  end

  it "sets the password" do
    post "/api/v1/admin/clients", params: payload, headers: headers, as: :json

    expect(Client.find_by!(email: "new-client@example.com").authenticate("secret123")).to be_truthy
  end

  describe "PATCH /api/v1/admin/clients/:id/state" do
    let(:client) { create(:client, state: "active") }

    it "changes the client to inactive" do
      patch "/api/v1/admin/clients/#{client.id}/state", params: { state: "inactive" }, headers: headers, as: :json

      expect(response.parsed_body["state"]).to eq("inactive")
    end

    context "with an unknown state" do
      it "rejects the state" do
        patch "/api/v1/admin/clients/#{client.id}/state", params: { state: "paused" }, headers: headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
