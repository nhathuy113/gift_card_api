class AuditLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  enum :outcome, { success: "success", refused: "refused" }, default: "success"

  scope :by_user, ->(id) { where(user_id: id) if id.present? }
  scope :by_action, ->(action) { where(action: action) if action.present? }
  scope :by_record, ->(type) { where(auditable_type: type) if type.present? }
  scope :from_date, ->(date) { where(created_at: Date.parse(date.to_s).beginning_of_day..) if date.present? }
  scope :to_date, ->(date) { where(created_at: ..Date.parse(date.to_s).end_of_day) if date.present? }

  def readonly? = persisted?
end
