require "rails_helper"

RSpec.describe Auditable do
  let(:admin) { create(:admin) }

  it "records a brand create" do
    brand = Current.set(user: admin) { Brand.create!(name: "Nike") }
    log = AuditLog.last

    expect(log.attributes.slice("action", "auditable_id", "user_id", "before_values")).to eq(
      "action" => "brand.create",
      "auditable_id" => brand.id,
      "user_id" => admin.id,
      "before_values" => nil
    )
  end

  it "stores the created name" do
    Current.set(user: admin) { Brand.create!(name: "Nike") }

    expect(AuditLog.last.after_values["name"]).to eq("Nike")
  end

  it "records the previous and next name" do
    Current.set(user: admin) do
      brand = Brand.create!(name: "Adidas")
      brand.update!(name: "Adidas Originals")
    end

    expect(AuditLog.last.attributes.slice("action", "before_values", "after_values")).to eq(
      "action" => "brand.update",
      "before_values" => { "name" => "Adidas" },
      "after_values" => { "name" => "Adidas Originals" }
    )
  end

  it "skips an update that changes nothing" do
    brand = Current.set(user: admin) { Brand.create!(name: "Reebok") }

    expect { brand.update!(name: "Reebok") }.not_to change(AuditLog, :count)
  end

  it "records a brand destroy" do
    Current.set(user: admin) do
      brand = Brand.create!(name: "Vans")
      brand.destroy!
    end

    expect(AuditLog.last.attributes.slice("action", "before_values")).to include(
      "action" => "brand.destroy",
      "before_values" => hash_including("name" => "Vans")
    )
  end
end
