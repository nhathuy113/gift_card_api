require "rails_helper"

RSpec.describe Admin, type: :model do
  it { expect(build(:admin)).to be_valid }
  it { expect(build(:admin, payout_rate: 10)).not_to be_valid }
  it { expect(Admin.new.role).to eq("admin") }

  it "only returns admins" do
    admin = create(:admin)
    create(:client)
    expect(described_class.all).to contain_exactly(admin)
  end
end
