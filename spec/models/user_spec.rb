require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid" do
    expect(build(:user)).to be_valid
  end

  describe "email" do
    it "is invalid without an email" do
      expect(build(:user, email: nil)).not_to be_valid
    end

    it "is invalid when the format is wrong" do
      expect(build(:user, email: "not-an-email")).not_to be_valid
    end

    context "when the email already exists" do
      it "is invalid regardless of case" do
        create(:user, email: "test@example.com")
        expect(build(:user, email: "TEST@example.com")).not_to be_valid
      end
    end

    it "strips and downcases the email" do
      expect(create(:user, email: "  User@EXAMPLE.COM ").email).to eq("user@example.com")
    end
  end

  describe "password" do
    it "is invalid when blank" do
      expect(build(:user, password: nil)).not_to be_valid
    end

    it "is invalid when longer than 72 bytes" do
      expect(build(:user, password: "a" * 73)).not_to be_valid
    end
  end

  describe "role" do
    it "is invalid without a role" do
      expect(build(:user, role: nil)).not_to be_valid
    end
  end

  describe "payout_rate" do
    context "when client" do
      it "is invalid without a payout rate" do
        expect(build(:user, role: "client", payout_rate: nil)).not_to be_valid
      end

      it "is invalid above 100" do
        expect(build(:user, role: "client", payout_rate: 101)).not_to be_valid
      end

      it "is valid at 0" do
        expect(build(:user, role: "client", payout_rate: 0)).to be_valid
      end
    end

    context "when admin" do
      it "is valid without a payout rate" do
        expect(build(:user, role: "admin", payout_rate: nil)).to be_valid
      end

      it "is invalid with a payout rate" do
        expect(build(:user, role: "admin", payout_rate: 10)).not_to be_valid
      end

      it "is rejected by the database without model validation" do
        user = build(:user, role: "admin", payout_rate: 10)
        expect { user.save!(validate: false) }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end

  describe ".active" do
    it "excludes inactive users" do
      inactive = create(:user, :inactive)
      expect(User.active).not_to include(inactive)
    end
  end
end
