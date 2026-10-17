require "rails_helper"

RSpec.describe "Authentication API", type: :request do
  let(:password) { "secret123" }

  before do
    create(:admin, email: "admin@example.com", password:)
    create(:client, email: "client@example.com", password:, payout_rate: 15.5)
  end

  def login(email, pw = password)
    post "/api/v1/login", params: { email:, password: pw }
  end

  it "logs in an admin" do
    login("admin@example.com")

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["user"]).to include("email" => "admin@example.com", "role" => "admin")
    expect(response.parsed_body["user"].keys).not_to include("password", "password_digest")
  end

  it "logs in a client" do
    login("client@example.com")

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig("user", "payout_rate")).to eq(15.5)
  end

  it "rejects a bad login" do
    login("admin@example.com", "wrong")

    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body["error"]).to eq("Invalid email or password")
  end
end
