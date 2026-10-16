require "rails_helper"

RSpec.describe Auditable do
  let(:admin) { create(:admin) }

  before do
    Audit.user = admin
    Audit.ip = "127.0.0.1"
    Audit.user_agent = "RSpec"
  end

  after do
    Audit.user = nil
    Audit.ip = nil
    Audit.user_agent = nil
  end

  it "automatically audits create" do
    brand = nil
    expect {
      brand = Brand.create!(name: "Nike")
    }.to change(AuditLog, :count).by(1)

    log = AuditLog.last
    expect(log.action).to eq("brand.create")
    expect(log.auditable).to eq(brand)
    expect(log.user_id).to eq(admin.id)
    expect(log.after_values["name"]).to eq("Nike")
    expect(log.before_values).to be_nil
  end

  it "automatically audits update" do
    brand = Brand.create!(name: "Adidas")

    expect {
      brand.update!(name: "Adidas Originals")
    }.to change(AuditLog, :count).by(1)

    log = AuditLog.last
    expect(log.action).to eq("brand.update")
    expect(log.before_values).to eq("name" => "Adidas")
    expect(log.after_values).to eq("name" => "Adidas Originals")
  end

  it "does not audit when no attributes changed" do
    brand = Brand.create!(name: "Reebok")

    expect {
      brand.update!(name: "Reebok")
    }.not_to change(AuditLog, :count)
  end

  it "automatically audits destroy" do
    brand = Brand.create!(name: "Vans")

    expect {
      brand.destroy!
    }.to change(AuditLog, :count).by(1)

    log = AuditLog.last
    expect(log.action).to eq("brand.destroy")
    expect(log.before_values["name"]).to eq("Vans")
  end
end
