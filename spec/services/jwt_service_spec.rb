require "rails_helper"

RSpec.describe JwtService do
  let(:user) { instance_double(User, id: 1, role: "admin") }

  describe ".encode and .decode" do
    it "encodes and decodes payload with default 12-hour expiry" do
      freeze_time do
        token = described_class.encode(user)
        decoded = described_class.decode(token)

        expect(decoded[:user_id]).to eq(1)
        expect(decoded[:role]).to eq("admin")
        expect(decoded[:exp]).to eq(12.hours.from_now.to_i)
      end
    end

    it "returns nil for expired token" do
      token = travel_to(13.hours.ago) { described_class.encode(user) }
      expect(described_class.decode(token)).to be_nil
    end

    it "returns nil for tampered, malformed, or nil token" do
      valid_token = described_class.encode(user)
      expect(described_class.decode("#{valid_token}tampered")).to be_nil
      expect(described_class.decode("not.a.token")).to be_nil
      expect(described_class.decode(nil)).to be_nil
    end
  end
end
