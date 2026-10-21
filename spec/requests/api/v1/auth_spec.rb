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

  it "rejects an inactive client" do
    create(:client, :inactive, email: "off@example.com", password:, payout_rate: 10)

    login("off@example.com")

    expect(response).to have_http_status(:unauthorized)
  end

  it "rejects a token after the client is deactivated" do
    client = Client.find_by!(email: "client@example.com")
    token = JwtService.encode(client)
    client.update!(state: "inactive")

    get "/api/v1/client/products", headers: { "Authorization" => "Bearer #{token}" }

    expect(response).to have_http_status(:unauthorized)
  end

  it "rejects a bad login" do
    login("admin@example.com", "wrong")

    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body["error"]).to eq("Invalid email or password")
  end

  it "rejects a token without jti" do
    admin = User.find_by!(email: "admin@example.com")
    token = JWT.encode({ user_id: admin.id, role: admin.role, exp: 1.hour.from_now.to_i }, Rails.application.secret_key_base, "HS256")

    get "/api/v1/admin/brands", headers: { "Authorization" => "Bearer #{token}" }

    expect(response).to have_http_status(:unauthorized)
  end

  it "rejects an expired token" do
    login("admin@example.com")
    token = response.parsed_body.fetch("token")

    travel 2.hours do
      get "/api/v1/admin/brands", headers: { "Authorization" => "Bearer #{token}" }
    end

    expect(response).to have_http_status(:unauthorized)
  end

  it "revokes the current token" do
    login("admin@example.com")
    token = response.parsed_body.fetch("token")

    post "/api/v1/logout", headers: { "Authorization" => "Bearer #{token}" }

    expect(response).to have_http_status(:no_content)
  end

  it "rejects a revoked token" do
    login("admin@example.com")
    token = response.parsed_body.fetch("token")
    post "/api/v1/logout", headers: { "Authorization" => "Bearer #{token}" }

    get "/api/v1/admin/brands", headers: { "Authorization" => "Bearer #{token}" }

    expect(response).to have_http_status(:unauthorized)
  end
end
