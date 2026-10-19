class Card < ApplicationRecord
  ACTIVATION_NUMBER_FORMAT = /\A\d{16}\z/

  belongs_to :client
  belongs_to :product

  enum :status, { issued: "issued", cancelled: "cancelled" }, default: "issued"

  validates :activation_number, presence: true, uniqueness: true, format: { with: ACTIVATION_NUMBER_FORMAT }
  validates :price_value, numericality: { only_integer: true, greater_than: 0 }
  validates :payout_rate, numericality: { in: 0..100 }
  validates :issued_at, presence: true
end
