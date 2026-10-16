module Audit
  FILTERED = %w[pin password password_digest].freeze
  thread_mattr_accessor :user, :ip, :user_agent

  def self.record(action:, record: nil, before: nil, after: nil, outcome: :success, metadata: {})
    AuditLog.create!(
      user: user,
      action: action,
      auditable_type: record&.class&.name,
      auditable_id: record&.id,
      before_values: scrub(before),
      after_values: scrub(after),
      outcome: outcome,
      ip: ip,
      user_agent: user_agent,
      metadata: scrub(metadata) || {}
    )
  end

  def self.scrub(h) = h&.deep_stringify_keys&.except(*FILTERED)
end
