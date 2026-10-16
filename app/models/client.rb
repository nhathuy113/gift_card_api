class Client < User
  default_scope { client }
  after_initialize { self.role = :client if new_record? }

  has_many :client_accessible_products, dependent: :delete_all
  has_many :accessible_products, through: :client_accessible_products, source: :product

  validates :payout_rate, presence: true, numericality: { in: 0..100 }
end
