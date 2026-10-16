class User < ApplicationRecord
  has_secure_password

  normalizes :email, with: ->(email) { email.strip.downcase }

  enum :role, { admin: "admin", client: "client" }
  enum :state, { active: "active", inactive: "inactive" }, default: "active"

  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: { case_sensitive: false }
  validates :role, presence: true

  validates :payout_rate, presence: true,
                          numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
                          if: :client?
  validates :payout_rate, absence: true, if: :admin?

  def active_for_authentication?
    active?
  end
end
