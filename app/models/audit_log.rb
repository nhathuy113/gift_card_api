class AuditLog < ApplicationRecord
  HIDDEN = %w[pin password password_digest].freeze

  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  enum :outcome, { success: "success", refused: "refused" }, default: "success"

  scope :by_user, ->(user_id) { where(user_id: user_id) if user_id.present? }
  scope :by_action, ->(action) { where(action: action) if action.present? }
  scope :by_record, ->(record_type) { where(auditable_type: record_type) if record_type.present? }
  scope :from_date, ->(date) { where(created_at: Date.iso8601(date).beginning_of_day..) if date.present? }
  scope :to_date, ->(date) { where(created_at: ..Date.iso8601(date).end_of_day) if date.present? }

  def self.record(action:, record: nil, before: nil, after: nil, outcome: :success, metadata: {})
    create!(
      user: Current.user,
      action: action,
      auditable_type: auditable_type_for(record),
      auditable_id: record&.id,
      before_values: redact(before),
      after_values: redact(after),
      outcome: outcome,
      ip: Current.ip_address,
      user_agent: Current.user_agent,
      metadata: redact(metadata) || {}
    )
  end

  def readonly? = persisted?

  def self.auditable_type_for(record)
    return if record.nil?

    record.is_a?(User) ? record.role.camelize : record.class.name
  end

  def self.redact(values)
    values&.deep_stringify_keys&.except(*HIDDEN)
  end
  private_class_method :auditable_type_for, :redact
end
