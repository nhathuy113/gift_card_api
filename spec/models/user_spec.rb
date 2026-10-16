require "rails_helper"

RSpec.describe User, type: :model do
  it { expect(build(:user)).to be_valid }

  describe "validations" do
    it { expect(build(:user, email: nil)).not_to be_valid }
    it { expect(build(:user, password: "short")).not_to be_valid }

    it "rejects duplicate email regardless of case" do
      create(:user, email: "test@example.com")
      expect(build(:user, email: "TEST@example.com")).not_to be_valid
    end
  end

  describe "payout_rate" do
    it { expect(build(:user, :client, payout_rate: nil)).not_to be_valid }
    it { expect(build(:user, :client, payout_rate: 101)).not_to be_valid }
    it { expect(build(:user, :client, payout_rate: 0)).to be_valid }
    it { expect(build(:user, :admin, payout_rate: 10)).not_to be_valid }
  end

  it "normalizes email" do
    expect(create(:user, email: "  User@EXAMPLE.COM ").email).to eq("user@example.com")
  end

  it ".active excludes inactive users" do
    inactive = create(:user, :inactive)
    expect(User.active).not_to include(inactive)
  end

  it "enforces payout_rate rule in the database" do
    user = build(:user, :admin, payout_rate: 10)
    expect { user.save!(validate: false) }.to raise_error(ActiveRecord::StatementInvalid)
  end
end