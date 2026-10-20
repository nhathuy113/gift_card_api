class Audit::Base
  def self.write(model, before: nil, after: nil)
    AuditLog.record(
      action: "#{model.model_name.singular}.#{name.demodulize.downcase}",
      record: model,
      before: before,
      after: after
    )
  end
end
