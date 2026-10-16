class Card < ApplicationRecord
  belongs_to :client
  belongs_to :product

  enum :status, { issued: "issued", cancelled: "cancelled" }, default: "issued"

  validates :activation_number, presence: true, uniqueness: true
  validates :idempotency_key, presence: true, uniqueness: { scope: :client_id }
  validates :price_value, numericality: { only_integer: true, greater_than: 0 }
  validates :payout_rate, numericality: { in: 0..100 }
  validates :issued_at, presence: true

  def cancel
    updated = Card.where(id: id, status: "issued")
                  .update_all(status: "cancelled", cancelled_at: Time.current, updated_at: Time.current)
    reload if updated == 1
    updated == 1
  end

  def cancel!
    cancel || raise(ActiveRecord::RecordInvalid.new(self))
  end
end
