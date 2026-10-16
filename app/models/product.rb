class Product < ApplicationRecord
  enum :state, { active: "active", inactive: "inactive" }, default: "active"
  belongs_to :brand

  validates :name, presence: true
  validates :price_value, numericality: { only_integer: true, greater_than: 0 }
  validates :custom_fields, custom_fields: true
end
