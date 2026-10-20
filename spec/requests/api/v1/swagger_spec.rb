require "rails_helper"

RSpec.describe "GET /api-docs/v1/swagger.yaml" do
  it "lists the logout responses" do
    get "/api-docs/v1/swagger.yaml"

    responses = YAML.safe_load(response.body).dig("paths", "/api/v1/logout", "post", "responses")
    expect(responses.keys).to eq(%w[204 401])
  end

  it "requires an activation number to cancel" do
    get "/api-docs/v1/swagger.yaml"

    schema = YAML.safe_load(response.body).dig(
      "paths", "/api/v1/client/cards/cancel", "post",
      "requestBody", "content", "application/json", "schema"
    )
    expect(schema["required"]).to eq(["activation_number"])
  end

  it "lists the cancel responses" do
    get "/api-docs/v1/swagger.yaml"

    responses = YAML.safe_load(response.body).dig("paths", "/api/v1/client/cards/cancel", "post", "responses")
    expect(responses.keys).to eq(%w[200 401 403 404 422])
  end

  it "requires a state to change a client" do
    get "/api-docs/v1/swagger.yaml"

    schema = YAML.safe_load(response.body).dig(
      "paths", "/api/v1/admin/clients/{id}/state", "patch",
      "requestBody", "content", "application/json", "schema"
    )
    expect(schema).to eq("$ref" => "#/components/schemas/StateInput")
  end

  it "lists the client state responses" do
    get "/api-docs/v1/swagger.yaml"

    responses = YAML.safe_load(response.body).dig("paths", "/api/v1/admin/clients/{id}/state", "patch", "responses")
    expect(responses.keys).to eq(%w[200 401 403 404 422])
  end

  it "lists the brand report responses" do
    get "/api-docs/v1/swagger.yaml"

    responses = YAML.safe_load(response.body).dig("paths", "/api/v1/admin/reports/brands", "get", "responses")
    expect(responses.keys).to eq(%w[200 400 401 403])
  end

  it "requires brand report totals" do
    get "/api-docs/v1/swagger.yaml"

    schema = YAML.safe_load(response.body).dig(
      "components", "schemas", "BrandReport"
    )
    expect(schema["required"]).to include("issued_count", "cancelled_count")
  end

  it "lists the client report responses" do
    get "/api-docs/v1/swagger.yaml"

    responses = YAML.safe_load(response.body).dig("paths", "/api/v1/admin/reports/clients", "get", "responses")
    expect(responses.keys).to eq(%w[200 400 401 403])
  end

  it "lists the client spending report responses" do
    get "/api-docs/v1/swagger.yaml"

    responses = YAML.safe_load(response.body).dig("paths", "/api/v1/client/reports", "get", "responses")
    expect(responses.keys).to eq(%w[200 400 401 403])
  end
end
