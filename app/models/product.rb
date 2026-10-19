class Product < ApplicationRecord
  enum :state, { active: "active", inactive: "inactive" }, default: "active"
  belongs_to :brand
  has_many :client_accessible_products, dependent: :delete_all, inverse_of: :product
  has_many :clients, through: :client_accessible_products, source: :client, inverse_of: :accessible_products

  validates :name, presence: true
  validates :price_value, numericality: { only_integer: true, greater_than: 0 }
  validates :custom_fields, custom_fields: true

  scope :by_brand, ->(brand_id) { where(brand_id: brand_id) if brand_id.present? }
  scope :search_by_name, ->(query) {
    where("products.name ILIKE ?", "%#{sanitize_sql_like(query)}%") if query.present?
  }
end
