class Card < ApplicationRecord
  ACTIVATION_NUMBER_FORMAT = /\A\d{16}\z/

  after_create { Audit::Issue.write(self) }

  belongs_to :client
  belongs_to :product

  enum :status, { issued: "issued", cancelled: "cancelled" }, default: "issued"

  validates :activation_number, presence: true, uniqueness: true, format: { with: ACTIVATION_NUMBER_FORMAT }
  validates :price_value, numericality: { only_integer: true, greater_than: 0 }
  validates :payout_rate, numericality: { in: 0..100 }
  validates :issued_at, presence: true

  def cancel!
    unless issued?
      AuditLog.record(action: "card.cancel", record: self, outcome: :refused, metadata: { "reason" => I18n.t("cards.cancel.already_cancelled") })
      raise ActiveRecord::RecordInvalid.new(self)
    end

    update!(status: "cancelled", cancelled_at: Time.current)
    AuditLog.record(action: "card.cancel", record: self, before: { "status" => "issued" }, after: { "status" => "cancelled" })
  end
end
