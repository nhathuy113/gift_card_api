require "rails_helper"

RSpec.describe Audit do
  let(:user) { create(:user) }

  before do
    Audit.user = user
    Audit.ip = "127.0.0.1"
    Audit.user_agent = "RSpec Test"
  end

  after do
    Audit.user = nil
    Audit.ip = nil
    Audit.user_agent = nil
  end

  it "never stores pin or password" do
    Audit.record(action: "x", after: { "pin" => "1", "name" => "a" }, metadata: { password: "s", password_digest: "secret" })
    log = AuditLog.last
    expect(log.after_values).to eq("name" => "a")
    expect(log.metadata).to eq({})
  end

  it "captures request context and auditable record" do
    brand = create(:brand)
    Audit.record(
      action: "brand.create",
      record: brand,
      outcome: :success,
      metadata: { "note" => "created brand" }
    )

    log = AuditLog.last
    expect(log.user_id).to eq(user.id)
    expect(log.action).to eq("brand.create")
    expect(log.auditable).to eq(brand)
    expect(log.outcome).to eq("success")
    expect(log.ip).to eq("127.0.0.1")
    expect(log.user_agent).to eq("RSpec Test")
    expect(log.metadata).to eq("note" => "created brand")
  end

  it "enforces immutability on persisted audit log records" do
    Audit.record(action: "test.immutable")
    log = AuditLog.last

    expect { log.update(action: "modified") }.to raise_error(ActiveRecord::ReadOnlyRecord)
    expect { log.destroy }.to raise_error(ActiveRecord::ReadOnlyRecord)
  end
end
