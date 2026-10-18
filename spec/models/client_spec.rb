require "rails_helper"

RSpec.describe Client, type: :model do
  it { expect(build(:client)).to be_valid }
  it { expect(build(:client, payout_rate: nil)).not_to be_valid }
  it { expect(build(:client, payout_rate: 101)).not_to be_valid }
  it { expect(build(:client, payout_rate: 0)).to be_valid }
  it { expect(Client.new.role).to eq("client") }

  it "only returns clients" do
    create(:admin)
    client = create(:client)
    expect(described_class.all).to contain_exactly(client)
  end
end
