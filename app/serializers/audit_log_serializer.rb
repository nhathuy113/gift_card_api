class AuditLogSerializer
  include Alba::Resource

  attributes :id, :user_id, :action, :auditable_type, :auditable_id,
    :before_values, :after_values, :outcome, :ip, :user_agent, :metadata, :created_at
end
