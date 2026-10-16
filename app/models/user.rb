class User < ApplicationRecord
  has_secure_password

  normalizes :email, with: ->(email) { email.strip.downcase }

  enum :role, { admin: "admin", client: "client" }
  enum :state, { active: "active", inactive: "inactive" }, default: "active"

  scope :active, -> { where(state: "active") }

  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: { case_sensitive: false }
  validates :role, presence: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  validates :payout_rate, presence: true,
                          numericality: { in: 0..100 },
                          if: :client?
  validates :payout_rate, absence: true, if: :admin?

  def active_for_authentication?
    active?
  end
end
