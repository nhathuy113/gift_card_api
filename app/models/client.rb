class Client < User
  default_scope { client }
  after_initialize { self.role = :client if new_record? }

  validates :payout_rate, presence: true, numericality: { in: 0..100 }
end
