class Brand < ApplicationRecord
  include Auditable

  enum :state, { active: "active", inactive: "inactive" }, default: "active"
  has_many :products, dependent: :restrict_with_error
  has_many :cards, through: :products

  validates :name, presence: true, uniqueness: true
  validates :custom_fields, custom_fields: true
end
