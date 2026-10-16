class Admin < User
  default_scope { admin }
  after_initialize { self.role = :admin if new_record? }

  validates :payout_rate, absence: true
end
