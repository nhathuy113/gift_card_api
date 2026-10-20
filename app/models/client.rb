class Client < User
  include Auditable
  prepend AccessibleProductIds

  default_scope { client }
  after_initialize { self.role = :client if new_record? }

  has_many :client_accessible_products, dependent: :delete_all
  has_many :accessible_products, through: :client_accessible_products, source: :product, inverse_of: :clients
  has_many :cards, dependent: :restrict_with_error
  validates :payout_rate, presence: true, numericality: { in: 0..100 }
end
