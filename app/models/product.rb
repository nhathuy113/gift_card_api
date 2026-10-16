class Product < ApplicationRecord
  enum :state, { active: "active", inactive: "inactive" }, default: "active"
  belongs_to :brand
  has_many :client_accessible_products, dependent: :delete_all
  has_many :clients, through: :client_accessible_products

  scope :issuable, -> { active.joins(:brand).merge(Brand.active) }

  validates :name, presence: true
  validates :price_value, numericality: { only_integer: true, greater_than: 0 }
  validates :custom_fields, custom_fields: true
end
