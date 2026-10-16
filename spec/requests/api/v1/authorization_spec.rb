require "rails_helper"
require_relative "../../../support/test_endpoints_controllers"

RSpec.describe "Authorization" do
  let(:admin) { create(:admin) }
  let(:client) { create(:client) }

  def token(user)
    { "Authorization" => "Bearer #{JwtService.encode(user)}" }
  end

  it "rejects a missing token" do
    get "/api/v1/admin/test"

    expect(response).to have_http_status(:unauthorized)
  end

  it "allows an admin on an admin route" do
    get "/api/v1/admin/test", headers: token(admin)

    expect(response).to have_http_status(:ok)
  end

  it "forbids a client on an admin route" do
    get "/api/v1/admin/test", headers: token(client)

    expect(response).to have_http_status(:forbidden)
  end

  it "allows a client on a client route" do
    get "/api/v1/client/test", headers: token(client)

    expect(response).to have_http_status(:ok)
  end
end
