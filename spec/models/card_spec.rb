require "rails_helper"

RSpec.describe Card do
  it "is valid with the factory" do
    expect(build(:card)).to be_valid
  end
end
