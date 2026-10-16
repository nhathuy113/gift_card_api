module Auditable
  extend ActiveSupport::Concern

  included do
    after_create :audit_create, prepend: true
    after_update :audit_update, prepend: true
    before_destroy :audit_destroy, prepend: true
  end

  private

  def audit_create
    changes = saved_changes.except("updated_at")
    return if changes.empty?

    Audit.record(
      action: "#{model_name.singular}.create",
      record: self,
      after: changes.transform_values(&:last)
    )
  end

  def audit_update
    changes = saved_changes.except("updated_at")
    return if changes.empty?

    Audit.record(
      action: "#{model_name.singular}.update",
      record: self,
      before: changes.transform_values(&:first),
      after: changes.transform_values(&:last)
    )
  end

  def audit_destroy
    Audit.record(
      action: "#{model_name.singular}.destroy",
      record: self,
      before: attributes.except("updated_at")
    )
  end
end
