class Brand < ApplicationRecord
  include Auditable

  enum :state, { active: "active", inactive: "inactive" }, default: "active", validate: true
  has_many :products, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :custom_fields, custom_fields: true
end
