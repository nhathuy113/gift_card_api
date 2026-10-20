class Audit::Update < Audit::Base
  def self.write(model)
    changes = model.saved_changes.except("updated_at")
    return if changes.empty?

    super(model, before: changes.transform_values(&:first), after: changes.transform_values(&:last))
  end
end
