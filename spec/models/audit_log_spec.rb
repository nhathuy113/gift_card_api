require "rails_helper"

RSpec.describe AuditLog, type: :model do
  describe ".record" do
    let(:user) { create(:user) }

    before { Current.user = user }
    after { Current.reset }

    it "stores the user" do
      described_class.record(action: "login.success")

      expect(described_class.last.user_id).to eq(user.id)
    end

    it "stores Client for a client" do
      described_class.record(action: "login.success", record: user)

      expect(described_class.last.auditable_type).to eq("Client")
    end

    it "stores the name and drops the pin" do
      described_class.record(action: "x", after: { pin: "1", name: "a" })

      expect(described_class.last.after_values).to eq({ "name" => "a" })
    end

    it "drops the password from metadata" do
      described_class.record(action: "x", metadata: { password: "s" })

      expect(described_class.last.metadata).to eq({})
    end
  end

  describe "#readonly?" do
    let(:log) { described_class.record(action: "test.immutable") }

    it "rejects an update" do
      expect { log.update(action: "modified") }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end

    it "rejects a destroy" do
      expect { log.destroy }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end
end
