require "rails_helper"

RSpec.describe Card do
  it "is valid with the factory" do
    expect(build(:card)).to be_valid
  end

  it "cancels an issued card" do
    card = create(:card)

    expect(card.cancel).to be(true)
    expect(card.status).to eq("cancelled")
  end
end
