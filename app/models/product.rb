class Product < ApplicationRecord
  enum :state, { active: "active", inactive: "inactive" }, default: "active"
  belongs_to :brand
  has_many :client_accessible_products, dependent: :delete_all
  has_many :clients, through: :client_accessible_products

  has_many :cards, dependent: :restrict_with_error
  scope :issuable, -> { active.joins(:brand).merge(Brand.active) }
  scope :by_brand, ->(brand_id) { where(brand_id: brand_id) if brand_id.present? }
  scope :search_by_name, ->(query) {
    where("products.name ILIKE ?", "%#{sanitize_sql_like(query)}%") if query.present?
  }

  validates :name, presence: true
  validates :price_value, numericality: { only_integer: true, greater_than: 0 }
  validates :custom_fields, custom_fields: true
end
